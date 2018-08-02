cmake_minimum_required(VERSION 3.5)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Require C++11.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS Off)

add_compile_options(-Wall -Wextra -Wconversion -Wno-sign-conversion -Wno-unknown-pragmas)

include(HunterGate)
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.20.24.tar.gz"
    SHA1 "3e2037a462bcf2ec3440f60298d933e74ffd4df3"
)

project(evm2wasm)

include(ProjectBinaryen)

add_subdirectory(libs)

option(EVM2WASM_TOOLS ON)
if(EVM2WASM_TOOLS)
    add_subdirectory(tools)
endif()
