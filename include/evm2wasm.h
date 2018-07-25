#pragma once

#include <string>
#include <vector>

namespace evm2wasm {

std::string wast2wasm(const std::string& input, bool debug = false);
std::string evm2wast(const std::vector<uint8_t>& input, bool tracing = false);
std::string evmhex2wast(const std::string& input, bool tracing = false);
std::string evm2wasm(const std::vector<uint8_t>& input, bool tracing = false);
std::string evmhex2wasm(const std::string& input, bool tracing = false);

}
