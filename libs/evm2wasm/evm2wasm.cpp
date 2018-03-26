#include <evm2wasm.h>

#include <wasm-binary.h>
#include <wasm-s-parser.h>
#include <wasm-validator.h>

#include "evm2wast.h"

#include "evm2wast.h"

using namespace std;

namespace {

string wast2wasm(const string& input, bool debug = false) {
  wasm::Module module;

  try {
    if (debug) std::cerr << "s-parsing..." << std::endl;
    // FIXME: binaryen 1.37.28 actually modifies the input...
    //        as a workaround make a copy here
    string tmp = input;
    wasm::SExpressionParser parser(const_cast<char*>(tmp.c_str()));
    wasm::Element& root = *parser.root;
    if (debug) std::cerr << "w-parsing..." << std::endl;
    wasm::SExpressionWasmBuilder builder(module, *root[0]);
  } catch (wasm::ParseException& p) {
    if (debug) {
      std::cerr << "error in parsing input" << std::endl;
      p.dump(std::cerr);
    }
    return string();
  }

  if (!wasm::WasmValidator().validate(module)) {
    if (debug) std::cerr << "module is invalid" << std::endl;
    return string();
  }

  if (debug) std::cerr << "binarification..." << std::endl;
  wasm::BufferWithRandomAccess buffer(debug);
  wasm::WasmBinaryWriter writer(&module, buffer, debug);
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
  if (evm2wast(input.c_str(), input.size(), &output, &len) < 0)
    return string();
  string ret(output, output + len);
  free(output);
  return ret;
}

}

string evm2wasm(const string& input) {
  return wast2wasm(evm2wast_wrapper(input), true);
}
