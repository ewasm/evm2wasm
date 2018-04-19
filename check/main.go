package main

import (
  "fmt"
  "os/exec"
  "io/ioutil"
	"encoding/json"
	"strings"
	"path/filepath"
  "sync"
)

/*
func getTests(dir string) map[string][]string{

}

func getPassingTests() []string{

}
*/

type TestResult struct {
  testName string
  passed bool
}

type Queue struct {
  m *sync.Mutex
  tests []string
}

func NewQueue(tests []string) Queue {
  return Queue{&sync.Mutex{}, tests}
}

func getTests() map[string][]string {
  files, err := filepath.Glob("/home/jwasinger/projects/tests/GeneralStateTests/**/*.json")
	if err != nil {
    panic("foobar")
	}

	//fmt.Printf("files: %d\n", len(files))

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

func (q *Queue) Pop() string {
  q.m.Lock()
  defer q.m.Unlock()
  if len(q.tests) > 0 {
    val := q.tests[0]
    q.tests = q.tests[1:]
    return val
  } else {
    return ""
  }
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

func makeWorker(q *Queue) chan TestResult {
	outCh := make(chan TestResult)
	go func (q *Queue, ch chan TestResult) {
		for {
			val := q.Pop()
		  if val == "" {
        break
			}
			// run the test

			cmd := exec.Command("echo", "\"hello world\"")
			stdout, err := cmd.StdoutPipe()

			if err != nil {
				fmt.Println("err")
			}
			if err := cmd.Start(); err != nil {
				fmt.Println("err")
			}
			if b, err := ioutil.ReadAll(stdout); err == nil {
					fmt.Println(string(b))
			}

			passed := true
			outCh <- TestResult{val, passed}
		}
	} (q, outCh)
	return outCh
}

func main() {
	fmt.Println(getTests())
	/*
	q := NewQueue(files)
  num := 4
  outputChs := make(chan[]bool, num)
  for i := 0; i < num; i++ {
    outputChs[i] = makeWorker(&q)
  }

  outputCh := merge(outputChs)
  for result, ok := <-outputChs; ; ok {
    fmt.Println(result.testName)
  }
	*/

  // read 
}
