cmake_minimum_required(VERSION 3.5)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

project(evm2wasm)

add_executable(evm2wasm
    evm2wasm.cpp
)