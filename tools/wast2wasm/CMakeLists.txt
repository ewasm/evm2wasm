add_executable(wast2wasm main.cpp)
target_link_libraries(wast2wasm PRIVATE libevm2wasm)