#include <evm2wasm.h>

#include <wasm-binary.h>
#include <wasm-s-parser.h>
#include <wasm-validator.h>

#include <vector>
#include <sstream>

using namespace std;

namespace {

bool nibble2value(char input, unsigned& output) {
  if (input >= '0' && input <= '9') {
    output = input - '0';
    return true;
  } else if (input >= 'a' && input <= 'f') {
    output = input - 'a' + 10;
    return true;
  } else if (input >= 'A' && input <= 'F') {
    output = input - 'A' + 10;
    return true;
  }
  return false;
}

// Hand rolled hex parser, because cross platform error handling is
// more reliable than with strtol() and any of the built std function.
//
// Returns an empty vector if input is invalid (odd number of characters or invalid nibbles).
// Assumes input is whitespace free, therefore if input is non-zero long an empty output
// signals an error.
vector<uint8_t> hexstring2vector(const string& input) {
  size_t len = input.length();
  if (len % 2 != 0)
    return vector<uint8_t>{};
  vector<uint8_t> ret;
  for (size_t i = 0; i <= len - 2; i += 2) {
    unsigned lo, hi;
    if (!nibble2value(input[i], hi) || !nibble2value(input[i + 1], lo))
      return vector<uint8_t>{};
    ret.push_back(static_cast<uint8_t>((hi << 4) | lo));
  }
  return ret;
}

}

namespace evm2wasm {

string wast2wasm(const string& input, bool debug) {
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

string evm2wast(const string& input, bool tracing) {
  (void)input;
  (void)tracing;
  // FIXME: do evm magic here
  return "(module (export \"main\" (func $main)) (func $main))";
}

string evm2wasm(const string& input, bool tracing) {
  return wast2wasm(evm2wast(input, tracing));
}

}
