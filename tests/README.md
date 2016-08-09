# Code Tests
The code tests run a small segments of code switch are designed to test the 
effects of opcodes in combination with each other

# Opcode Tests
The opcode tests are design to test individual opcodes

## Schema
```
[{
  "op": The Opcode being tested
  "value": The opcodes hex value
  "description": A short description of the test
  "environment": {
    "caller": the callers address
  },
  "in": {
    "memory": {
      "index": 32 byte memory segment in hex
    },
    "stack": [ the initial stack  items in hex  ]
  },
  "out": {
    "stack": [the resulting stack items in hex],
    "memory": {
      "index": 32 byte memory segment in hex
    },
    "return": the resulting return value if any
    "cacluatedGasUsed": the gas used by the operation not including it base gas cost 
  }
}]
```
## Example

```
[{
  "op": "RETURN",
  "value": "0xf3",
  "description": "return 0x42",
  "in": {
    "memory": {
      "512": "0x000000000000000000000000000000000000000000000000000000000000002a"
    },
    "stack": [
      "0x0000000000000000000000000000000000000000000000000000000000000020",
      "0x0000000000000000000000000000000000000000000000000000000000000200"
    ]
  },
  "out": {
    "stack": [],
    "memory": {
      "512": "0x000000000000000000000000000000000000000000000000000000000000002a"
    },
    "return": "0x000000000000000000000000000000000000000000000000000000000000002a"
  }
}]
```
