from subprocess import Popen, PIPE
from os import path
import glob, json

# yield test file name and test cases in file
def iterate_test_cases(tests_path):
  for file_name in glob.glob(path.join(tests_path, "GeneralStateTests/**/*.json")):
    test_case_names = []

    try:
      with open(file_name) as f:
        test_cases = json.load(f)
        test_case_names = test_cases.keys()
    except Exception as e:
      print("{0}: {1}".format(file_name, e))
      yield None

    yield (file_name, test_case_names)

def get_previously_passing_tests():
  with open("passing_tests.txt") as f:
    return list(f)

def main():
  prev_passing_tests = get_previously_passing_tests()

  for d in iterate_test_cases("/home/jwasinger/projects/tests"):
    file_name = d[0]
    test_cases = d[1]

    for test_case in test_cases:
      cmd = ['testeth',  '-t',  'GeneralStateTests', '--', '--singlenet', 'Byzantium', '--singletest', file_name, test_case, '--vm', 'hera', '--evmc', 'evm2wasm.js=true']
      p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)
      output, err = p.communicate()
      print("ran {0}".format(" ".join(cmd)))
      print(output)
      import pdb; pdb.set_trace()
      if err and "expected" in err:
        if test_case in prev_passing_tests:
          print("previously passing test is now failing")
          os.exit(1)
      else:
        if not test_case in prev_passing_tests:
          prev_passing_tests.append(test_case)

      rc = p.returncode

  import pdb; pdb.set_trace()
  prev_passing_tests = sorted(prev_passing_tests, key=lambda item: (int(item.partition(' ')[0])
                                 if item[0].isdigit() else float('inf'), item))

  with open("passing_tests.txt", "w") as f:
    f.write('\n'.join(prev_passing_tests))

if __name__ == "__main__":
  main()
