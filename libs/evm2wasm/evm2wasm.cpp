#include <evm2wasm.h>

#include "wasm-binary.h"
#include "wasm-s-parser.h"
#include "evm2wast.h"

using namespace std;

namespace {

string wast2wasm(string input, bool debug = true) {
  wasm::Module wasm;

  try {
    if (debug) std::cerr << "s-parsing..." << std::endl;
    wasm::SExpressionParser parser(const_cast<char*>(input.c_str()));
    wasm::Element& root = *parser.root;
    if (debug) std::cerr << "w-parsing..." << std::endl;
    wasm::SExpressionWasmBuilder builder(wasm, *root[0]);
  } catch (wasm::ParseException& p) {
    p.dump(std::cerr);
    wasm::Fatal() << "error in parsing input";
	} 

  if (debug) std::cerr << "binarification..." << std::endl;
  wasm::BufferWithRandomAccess buffer(debug);
  wasm::WasmBinaryWriter writer(&wasm, buffer, debug);
  writer.write();

  if (debug) std::cerr << "writing to output..." << std::endl;

  ostringstream output;
  buffer.writeTo(output);

  if (debug) std::cerr << "Done." << std::endl;
  
  return output.str();
}

string evm2wast_wrapper(string input) {
  size_t len = 0;
  char *output = NULL;
  if (evm2wast(const_cast<char*>(input.c_str()), input.size(), &output, &len) < 0)
    return string();
  string ret(output, output + len);
  free(output);
	cout << ret << endl;
  return ret;
}

string evm2wasm(string input) {
  return wast2wasm(evm2wast_wrapper(input));
}

}

int main(int argc, char **argv) {
	if(argc<2) {
		cout << "usage " << argv[0] << " <evm file>" << endl;
		return 1;
	}
	FILE *fd = fopen(argv[1], "r");
	fseek(fd, 0, SEEK_END);
	size_t offset = ftell(fd);
	rewind(fd);
	char *code = (char*)malloc(8192);
	fread(code, 1, 8192, fd);
	fclose(fd);
  cout << evm2wasm(string(code)) << endl;
	return 0;
}
