set(include_dir ${PROJECT_SOURCE_DIR}/include)

add_custom_target(gen_gadgets
    ${CMAKE_CURRENT_SOURCE_DIR}/gen_gadgets.sh
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/gadgets.c
)

add_library(libevm2wasm
    evm2wasm.cpp ${include_dir}/evm2wasm.h
    evm2wast.c
    gadgets.c
)
set_target_properties(libevm2wasm PROPERTIES OUTPUT_NAME evm2wasm)

add_dependencies(libevm2wasm gen_gadgets)

target_include_directories(libevm2wasm PUBLIC ${include_dir})
target_link_libraries(libevm2wasm PRIVATE binaryen::binaryen)