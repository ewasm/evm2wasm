#include <evm2wasm.h>

#include "wasm-binary.h"
#include "wasm-s-parser.h"

using namespace std;

namespace {

string wast2wasm(const string& input, bool debug = false) {
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

  // FIXME: perhaps call validate() here?

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

string evm2wast(string input) {
  (void)input;
  // FIXME: do evm magic here
  return "(module (func $test))";
}

}

string evm2wasm(const string& input) {
    return wast2wasm(evm2wast(input));
}
