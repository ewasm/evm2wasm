# SYNOPSIS 
[![CircleCI](https://circleci.com/gh/ewasm/evm2wasm.svg?style=svg)](https://circleci.com/gh/ewasm/evm2wasm)
[![js-standard-style](https://cdn.rawgit.com/feross/standard/master/badge.svg)](https://github.com/feross/standard)  

EVM (Ethereum VM 1.0) to [eWASM](https://github.com/ewasm/design) transcompiler. Here is a online [frontend](https://ewasm.github.io/evm2wasm-frontend/dist/).

# INSTALL
Clone the repository and run `npm install`

# USE
There is a commandline tool to transcompile EVM input:

#### Transcompile EVM to WASM
```
$ bin/evm2wasm.js -e `evm_bytecode_file` -o `wasm_output_file`
```

#### Transcompile EVM to WAST
```
$ bin/evm2wasm.js -e `evm_bytecode_file` -o `wasm_output_file` --wast
```

#### Transcompile EVM to WAST with embedded EVM trace statements for each transpiled EVM opcode
```
$ bin/evm2wasm.js -e `evm_bytecode_file` -o `wasm_output_file` --wast --trace
```

#### Transcompile EVM to WAST with gas metering per transpiled EVM opcode (not per branch segment)
```
$ bin/evm2wasm.js -e `evm_bytecode_file` -o `wasm_output_file` --wast --charge-per-op
```

# DEVELOP
* After any changes to `.wast` file, `npm run build` needs to be run to compile the files into a .json file 
* To rebuild the documentation run `npm run build:docs`
* To lint run `npm run lint`
* And make sure you test with `npm test` and `npm run vmTests` which runs the offical Ethereum test suite

The above build command will invoke `wasm/generateInterface.js` which generates `wasm/wast.json` and `include/wast.h` containing a
Webassembly function corresponding to each EVM opcode.

The core logic of the evm2wasm compiler is in `index.js` (Javascript frontend) or `libs/evm2wasm/evm2wasm.cpp` (C++ fronetend), which iterates the input EMV bytecode and generates
a Webassembly output by invoking each of the above generated Webassembly functions and concatenating them into the output.

To build the C++ frontend:
```
$ mkdir build
$ cd build
$ cmake ..
$ make
```

# API
[./docs/](./docs/index.md)

# TECHNICAL NOTES  
EVM is stack based and offers access to memory, storage and state via special instructions.  
Here we replicate the stack layout in WebAssembly (WASM) and implement each operation working on this stack.

### OPCODES  
Every opcode (bar some special instructions) receives the current stack pointer (`$sp`) as `i32` and must return the adjusted stack pointer.

### STACK LAYOUT  
The stack grows from memory location 0, where 256 bit values are stored linearly in LSB byteorder.  
The `$sp` points to the starting position of the top stack entry (and not the next free stack position). If the stack is empty, it is set to `-32`.

### MEMORY LAYOUT  
The resulting (after transpilation) contract memory layout is currently as follows:
```
.---------------------------------------------------
| Reserved space for the stack (32768 bytes)
| - each stack entry is 256 bits
| - the stack is limited to 1024 entries
+---------------------------------------------------
| Word count (4 bytes)
| (Number of 256 bit words stored in memory)
+---------------------------------------------------
| Previous memory cost in word count (4 bytes)
| (The cost charged for the last memory allocation)
+---------------------------------------------------
| Scratch space (32 bytes)
+---------------------------------------------------
| Reserved space for the Keccak-256 context (1024 bytes)
+---------------------------------------------------
| "EVM 1.0" contract memory starts here ("unlimited" in size)
`---------------------------------------------------
```

### METERING  
The generated *eWASM contract* contains gas metering. It is assumed *evm2wasm* will become a deployed trusted contract, which returns eWASM code that does not need to be run through the gas injector contract.

# LICENSE
[MPL-2.0](https://tldrlegal.com/license/mozilla-public-license-2.0-(mpl-2))

