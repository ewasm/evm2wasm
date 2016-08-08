# Opcode Tests

## Schema
```
[{
  "op": The Opcode being tested,
  "value": The opcodes hex value
  "description": A short description of the test
  in": {
    "memory": {
      "index": 32 byte memory segment in hex
    },
    "stack": [ the initial stack items in hex  ]
  },
  "out": {
    "stack": [the resulting stack items in hex],
    "memory": {
      "index": 32 byte memory segment in hex
    },
    "return": the resulting return value if any
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
