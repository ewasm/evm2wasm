#include <evm2wasm.h>
#include <iostream>

int main(int argc, char **argv) {
    (void)argc;
    (void)argv;
    std::cout << evm2wasm("600160020200") << std::endl;
    return 0;
}