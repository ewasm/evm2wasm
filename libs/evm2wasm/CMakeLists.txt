set(include_dir ${PROJECT_SOURCE_DIR}/include)

find_package(Threads REQUIRED)

add_library(libevm2wasm
    evm2wasm.cpp ${include_dir}/evm2wasm.h
)
set_target_properties(libevm2wasm PROPERTIES OUTPUT_NAME evm2wasm)

target_include_directories(libevm2wasm PUBLIC ${include_dir})
target_link_libraries(libevm2wasm PRIVATE binaryen::binaryen Threads::Threads)