#pragma once

#include <string>

std::string wast2wasm(const std::string& input, bool debug = false);
std::string evm2wasm(const std::string& input);
