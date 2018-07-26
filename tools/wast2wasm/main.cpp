#include <fstream>
#include <iostream>
#include <streambuf>
#include <string>

#include <evm2wasm.h>

using namespace std;

int main(int argc, char** argv)
{
    (void)argc;
    (void)argv;

    string input;
    while (!cin.eof())
    {
        string tmp;
        // NOTE: this will read until EOF or NL
        getline(cin, tmp);
        input.append(tmp);
        input.append("\n");
    }

    if (!input.size())
        return 1;

    string output = evm2wasm::wast2wasm(input);

    if (!output.size())
        return 1;

    cout << output << endl;

    return 0;
}
