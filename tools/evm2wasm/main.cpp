#include <string>
#include <iostream>
#include <fstream>
#include <streambuf>
#include <evm2wasm.h>

using namespace std;

int main(int argc, char **argv) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <EVM file>" << endl;
        return 1;
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

    cout << evm2wasm(str) << endl;

    return 0;
}
