package main

import (
  "fmt"
  "os/exec"
  "os"
  "io/ioutil"
	"encoding/json"
	"strings"
	"path/filepath"
  "sync"
  "sort"
  "bufio"
  //"bytes"
)

/*
func getTests(dir string) map[string][]string{

}

func getPassingTests() []string{

}
*/

//map a test file name to the list of cases it contains
type TestCases = map[string][]string

type TestResult struct {
  testName string
  passed bool
}

type MapQueue struct {
  m *sync.Mutex
  tests TestCases
}

func NewMapQueue(tests TestCases) MapQueue {
  return MapQueue{&sync.Mutex{}, tests}
}

func (q *MapQueue) Pop() (string, []string) {
  q.m.Lock()
  defer q.m.Unlock()
  if len(q.tests) > 0 {
    for k, v := range q.tests {
      delete(q.tests, k)
      return k, v
    }

    return "", nil
  } else {
    return "", nil
  }
}

func getTests() TestCases {
  files, err := filepath.Glob(os.Args[1]+"/GeneralStateTests/**/*.json")
	if err != nil {
    panic("foobar")
	}

	testInfo := make(map[string]struct{}) //raw json object for test
	tests := make(map[string][]string)

	for _, f := range files {
		jsonStream, err := ioutil.ReadFile(f)
		if err != nil {
      panic("err")
		}

		jsonString := string(jsonStream)

	  dec := json.NewDecoder(strings.NewReader(jsonString))
    err = dec.Decode(&testInfo)
    if err != nil {
		  panic("err")
    }

		tests[f] = make([]string, len(testInfo))
		for k, _ := range testInfo {
      tests[f] = append(tests[f], k)
		}
	}

	return tests
}


// merge a bunch of channels into one
func merge(cs ...<-chan TestResult) <-chan TestResult{
    var wg sync.WaitGroup
    out := make(chan TestResult)

    // Start an output goroutine for each input channel in cs.  output
    // copies values from c to out until c is closed, then calls wg.Done.
    output := func(c <-chan TestResult) {
        for n := range c {
            out <- n
        }
        wg.Done()
    }
    wg.Add(len(cs))
    for _, c := range cs {
        go output(c)
    }

    // Start a goroutine to close out once all the output goroutines are
    // done.  This must start after the wg.Add call.
    go func() {
        wg.Wait()
        close(out)
    }()
    return out
}

func runTestCase() bool {
  testPath := "/home/jwasinger/projects/tests"
  testFile := "/home/jwasinger/projects/tests/GeneralStateTests/stExample/add11.json"
  testName := "add11"

  cmd_str := "/home/jwasinger/projects/cpp-ethereum/build/test/testeth"
  cmd_args := []string{"-t", "GeneralStateTests/stExample", "--", "--testpath", testPath, "--singlenet", "Byzantium", "--singletest", testFile, testName}

  //var out bytes.Buffer
  cmd := exec.Command(cmd_str, cmd_args...)
	cmd.Env = os.Environ()
	cmd.Env = append(cmd.Env, "ETHEREUM_TEST_PATH=/home/jwasinger/projects/tests")
  //cmd.Stderr = &out

  /*
  stdout, err := cmd.StdoutPipe()
  if err != nil {
    fmt.Println(err)
  }
  */

  /*
  if err := cmd.Start(); err != nil {
    fmt.Println(err)
  }
  if err := cmd.Wait(); err != nil {
    fmt.Println(err)
  }
  */

  output, err := cmd.CombinedOutput()
  if err != nil {
    fmt.Println(err)
  }

  fmt.Println(string(output[:len(output)]))
  return true

  /*
  if _, err := ioutil.ReadAll(stdout); err == nil {
    fmt.Println("foobar")
    return true
  } else {
    fmt.Println(err)
    fmt.Println("foobar2")
    return false
  }
  */
}

func makeWorker(q *MapQueue) chan TestResult {
	outCh := make(chan TestResult)
	go func (q *MapQueue, ch chan TestResult) {
    defer close(ch)
		for {
			file, cases:= q.Pop()
		  if file == "" || cases == nil {
        break
			}

      runTestCase()
			passed := true
			outCh <- TestResult{file, passed}
		}
	} (q, outCh)
	return outCh
}

func loadPrevPassingTests() []string {
		stream, err := ioutil.ReadFile("passing_tests.txt")
		if err != nil {
      panic("err")
		}

		return  strings.Split(string(stream), "\n")
}

func contains(arr []string, val string) bool {
  for _, v := range arr {
    if v == val {
      return true
    }
  }
  return false
}

func writeoutTests(tests []string) {
  f, err := os.Create("passing_tests.txt")
  if err != nil {
    fmt.Println(err)
  }

  w := bufio.NewWriter(f)
  for _, test := range tests {
    fmt.Fprintln(w, test)
    //fmt.Println(test)
  }
  w.Flush()
}

func main() {
  prevPassingTests := loadPrevPassingTests()
  passingTests := make([]string, 0)
	tests := getTests()

	q := NewMapQueue(tests)
  num := 50
  outputChs := make([]<-chan TestResult, num)
  for i := 0; i < num; i++ {
    outputChs[i] = makeWorker(&q)
  }

  outputCh := merge(outputChs...)
  for result := range outputCh {
    if contains(prevPassingTests, result.testName) && !result.passed {
      panic("previously-passing test is now failing")
    }

    if result.passed {
      passingTests = append(passingTests, result.testName)
    }
  }

  sort.Strings(passingTests)
  writeoutTests(passingTests)
  return
  // read 
}
