cmake_minimum_required(VERSION 3.5)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

project(evm2wasm)

include(ProjectBinaryan)

add_executable(evm2wasm
    evm2wasm.cpp
)

target_link_libraries(evm2wasm PRIVATE binaryen::binaryen)