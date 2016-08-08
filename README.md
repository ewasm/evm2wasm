# evm2wasm

EVM (Ethereum VM 1.0) to [eWASM](https://github.com/ethereum/evm2.0-design) transcompiler.

### Tech

EVM is stack based and offers access to memory, storage and state via special instructions.

Here we replicate the stack layout in WebAssembly and implement each operation working on this stack.

### Opcodes

Every opcode (bar some special instructions) receives the current stack pointer (`$sp`) as `i32` and must return the adjusted stack pointer.

### Stack layout

The stack grows from memory location 0, where 256 bit values are stored linearly in LSB byteorder.

The `$sp` points to the starting position of the top stack entry (and not the next free stack position). If the stack is empty, it is set to `-32`.

### Memory layout

The eWASM contract memory layout is currently as follows:

```
.---------------------------------------------------
| eWASM memory starts here
+---------------------------------------------------
| Reserved space for the stack (32768 bytes)
| - each stack entry is 256 bit
| - stack is limited to 1024 entries
+---------------------------------------------------
| Reserved space for state operations (32 bytes)
| - single 256 bit slot
+---------------------------------------------------
| Reserved space for SHA3 (1024 bytes)
| - 1024 bytes for the SHA3 context
+---------------------------------------------------
| Contract memory starts here ("unlimited" in size)
`---------------------------------------------------
```

### Gas metering

The generated *eWASM contract* contains gas metering. It is assumed *evm2wasm* will become a deployed trusted contract, which returns eWASM code that
does not need to be run through the gas injector contract.
