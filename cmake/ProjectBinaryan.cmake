include(ExternalProject)

ExternalProject_Add(binaryen
    PREFIX deps
    DOWNLOAD_NAME binaryen-1.37.28.tar.gz
    DOWNLOAD_DIR ${CMAKE_SOURCE_DIR}/deps/downloads
    URL https://github.com/WebAssembly/binaryen/archive/1.37.28.tar.gz
    URL_HASH SHA256=90395016042d187c9be876eb18290ef839d55b58643f654b10aa9d5c98fc8703
    CMAKE_ARGS
    -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_STATIC_LIB=ON
    # Overwtire build and install commands to force Release build on MSVC.
    BUILD_COMMAND cmake --build <BINARY_DIR> --config Release
    INSTALL_COMMAND cmake --build <BINARY_DIR> --config Release --target install
)

ExternalProject_Get_Property(binaryen INSTALL_DIR BINARY_DIR SOURCE_DIR)
add_library(binaryen::binaryen STATIC IMPORTED)
set(binaryen_library ${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}binaryen${CMAKE_STATIC_LIBRARY_SUFFIX})
# Use source dir because binaryen only installs single header with C API.
set(binaryen_include_dir ${SOURCE_DIR}/src)
file(MAKE_DIRECTORY ${binaryen_include_dir})  # Must exist.
set_target_properties(
    binaryen::binaryen
    PROPERTIES
    IMPORTED_LOCATION ${binaryen_library}
    INTERFACE_INCLUDE_DIRECTORIES ${binaryen_include_dir}
    INTERFACE_LINK_LIBRARIES
# Include also other static libs needed:
"${BINARY_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}wasm${CMAKE_STATIC_LIBRARY_SUFFIX};\
${BINARY_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}asmjs${CMAKE_STATIC_LIBRARY_SUFFIX};\
${BINARY_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}passes${CMAKE_STATIC_LIBRARY_SUFFIX};\
${BINARY_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}support${CMAKE_STATIC_LIBRARY_SUFFIX}"
)

add_dependencies(binaryen::binaryen binaryen)
unset(INSTALL_DIR)
unset(SOURCE_DIR)
unset(BUILD_DIR)