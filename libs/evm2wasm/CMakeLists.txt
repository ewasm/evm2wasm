set(include_dir ${PROJECT_SOURCE_DIR}/include)

find_package(Threads REQUIRED)

hunter_add_package(fmt)

find_package(fmt CONFIG REQUIRED)

add_library(libevm2wasm STATIC
    evm2wasm.cpp ${include_dir}/evm2wasm.h
)
set_target_properties(libevm2wasm PROPERTIES OUTPUT_NAME evm2wasm)

if(BUILD_SHARED_LIBS)
  set_target_properties(libevm2wasm PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
endif()

target_include_directories(libevm2wasm PUBLIC $<BUILD_INTERFACE:${include_dir}>$<INSTALL_INTERFACE:include>)
target_link_libraries(libevm2wasm PRIVATE binaryen::binaryen Threads::Threads fmt::fmt)

install(TARGETS libevm2wasm EXPORT evm2wasmTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
