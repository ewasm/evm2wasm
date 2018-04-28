#include <string>
#include <iostream>
#include <fstream>
#include <streambuf>
#include <algorithm>

#include <evm2wasm.h>

using namespace std;


int main(int argc, char **argv) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <EVM file> [--wast]" << endl;
        return 1;
    }

    bool wast = false;
    if (argc == 3) {
        wast = (string(argv[2]) == "--wast");
        if (!wast) {
            cerr << "Usage: " << argv[0] << " <EVM file> [--wast]" << endl;
            return 1;
        }
    }

    ifstream input(argv[1]);
    if (!input.is_open()) {
        cerr << "File not found: " << argv[1] << endl;
        return 1;
    }

    string str(
        (std::istreambuf_iterator<char>(input)),
        std::istreambuf_iterator<char>()
    );

    // clean input of any whitespace (including space and new lines)
    str.erase(remove_if(str.begin(), str.end(), [](unsigned char x){return std::isspace(x);}), str.end());

    if (wast) {
        cout << evm2wasm::evmhex2wast(str);
    } else {
        cout << evm2wasm::evmhex2wasm(str);
    }

    return 0;
}
