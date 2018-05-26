#pragma once

#include <string>

namespace evm2wasm {

std::string wast2wasm(const std::string& input, bool debug = false);
std::string evm2wast(const std::string& input);
std::string evm2wasm(const std::string& input);

}
