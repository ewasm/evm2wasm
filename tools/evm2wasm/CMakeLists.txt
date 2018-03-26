add_executable(evm2wasm main.cpp)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(evm2wasm PRIVATE libevm2wasm Threads::Threads)
