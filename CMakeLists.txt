cmake_minimum_required(VERSION 3.5)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Require C++11.
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS Off)

project(evm2wasm)

include(ProjectBinaryen)

add_custom_target(gen_gadgets
	${PROJECT_SOURCE_DIR}/gen_gadgets.sh
	WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

add_executable(evm2wasm
    evm2wasm.cpp
    evm2wast.c
		gadgets.c
)
add_dependencies(evm2wasm gen_gadgets)
target_link_libraries(evm2wasm PRIVATE binaryen::binaryen)
