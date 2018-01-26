const codes = {
  // 0x0 range - arithmetic ops
  // name, baseCost, off stack, on stack
  0x00: ['STOP', 0, 0, 0],
  0x01: ['ADD', 3, 2, 1],
  0x02: ['MUL', 5, 2, 1],
  0x03: ['SUB', 3, 2, 1],
  0x04: ['DIV', 5, 2, 1],
  0x05: ['SDIV', 5, 2, 1],
  0x06: ['MOD', 5, 2, 1],
  0x07: ['SMOD', 5, 2, 1],
  0x08: ['ADDMOD', 8, 3, 1],
  0x09: ['MULMOD', 8, 3, 1],
  0x0a: ['EXP', 10, 2, 1],
  0x0b: ['SIGNEXTEND', 5, 2, 1],

  // 0x10 range - bit ops
  0x10: ['LT', 3, 2, 1],
  0x11: ['GT', 3, 2, 1],
  0x12: ['SLT', 3, 2, 1],
  0x13: ['SGT', 3, 2, 1],
  0x14: ['EQ', 3, 2, 1],
  0x15: ['ISZERO', 3, 1, 1],
  0x16: ['AND', 3, 2, 1],
  0x17: ['OR', 3, 2, 1],
  0x18: ['XOR', 3, 2, 1],
  0x19: ['NOT', 3, 1, 1],
  0x1a: ['BYTE', 3, 2, 1],

  // 0x20 range - crypto
  0x20: ['SHA3', 30, 2, 1],

  // 0x30 range - closure state
  0x30: ['ADDRESS', 0, 0, 1],
  0x31: ['BALANCE', 0, 1, 1],
  0x32: ['ORIGIN', 0, 0, 1],
  0x33: ['CALLER', 0, 0, 1],
  0x34: ['CALLVALUE', 0, 0, 1],
  0x35: ['CALLDATALOAD', 0, 1, 1],
  0x36: ['CALLDATASIZE', 0, 0, 1],
  0x37: ['CALLDATACOPY', 0, 3, 0],
  0x38: ['CODESIZE', 0, 0, 1],
  0x39: ['CODECOPY', 0, 3, 0],
  0x3a: ['GASPRICE', 0, 0, 1],
  0x3b: ['EXTCODESIZE', 0, 1, 1],
  0x3c: ['EXTCODECOPY', 0, 4, 0],

  // '0x40' range - block operations
  0x40: ['BLOCKHASH', 0, 1, 1],
  0x41: ['COINBASE', 0, 0, 1],
  0x42: ['TIMESTAMP', 0, 0, 1],
  0x43: ['NUMBER', 0, 0, 1],
  0x44: ['DIFFICULTY', 0, 0, 1],
  0x45: ['GASLIMIT', 0, 0, 1],

  // 0x50 range - 'storage' and execution
  0x50: ['POP', 2, 1, 0],
  0x51: ['MLOAD', 3, 1, 1],
  0x52: ['MSTORE', 3, 2, 0],
  0x53: ['MSTORE8', 3, 2, 0],
  0x54: ['SLOAD', 0, 1, 1],
  0x55: ['SSTORE', 0, 2, 0],
  0x56: ['JUMP', 8, 0, 0],
  0x57: ['JUMPI', 10, 0, 0],
  0x58: ['PC', 2, 0, 1],
  0x59: ['MSIZE', 2, 0, 1],
  0x5a: ['GAS', 0, 0, 1],
  0x5b: ['JUMPDEST', 0, 0, 0],

  // 0x60, range
  0x60: ['PUSH', 3, 0, 1],
  0x61: ['PUSH', 3, 0, 1],
  0x62: ['PUSH', 3, 0, 1],
  0x63: ['PUSH', 3, 0, 1],
  0x64: ['PUSH', 3, 0, 1],
  0x65: ['PUSH', 3, 0, 1],
  0x66: ['PUSH', 3, 0, 1],
  0x67: ['PUSH', 3, 0, 1],
  0x68: ['PUSH', 3, 0, 1],
  0x69: ['PUSH', 3, 0, 1],
  0x6a: ['PUSH', 3, 0, 1],
  0x6b: ['PUSH', 3, 0, 1],
  0x6c: ['PUSH', 3, 0, 1],
  0x6d: ['PUSH', 3, 0, 1],
  0x6e: ['PUSH', 3, 0, 1],
  0x6f: ['PUSH', 3, 0, 1],
  0x70: ['PUSH', 3, 0, 1],
  0x71: ['PUSH', 3, 0, 1],
  0x72: ['PUSH', 3, 0, 1],
  0x73: ['PUSH', 3, 0, 1],
  0x74: ['PUSH', 3, 0, 1],
  0x75: ['PUSH', 3, 0, 1],
  0x76: ['PUSH', 3, 0, 1],
  0x77: ['PUSH', 3, 0, 1],
  0x78: ['PUSH', 3, 0, 1],
  0x79: ['PUSH', 3, 0, 1],
  0x7a: ['PUSH', 3, 0, 1],
  0x7b: ['PUSH', 3, 0, 1],
  0x7c: ['PUSH', 3, 0, 1],
  0x7d: ['PUSH', 3, 0, 1],
  0x7e: ['PUSH', 3, 0, 1],
  0x7f: ['PUSH', 3, 0, 1],

  0x80: ['DUP', 3, 0, 1],
  0x81: ['DUP', 3, 0, 1],
  0x82: ['DUP', 3, 0, 1],
  0x83: ['DUP', 3, 0, 1],
  0x84: ['DUP', 3, 0, 1],
  0x85: ['DUP', 3, 0, 1],
  0x86: ['DUP', 3, 0, 1],
  0x87: ['DUP', 3, 0, 1],
  0x88: ['DUP', 3, 0, 1],
  0x89: ['DUP', 3, 0, 1],
  0x8a: ['DUP', 3, 0, 1],
  0x8b: ['DUP', 3, 0, 1],
  0x8c: ['DUP', 3, 0, 1],
  0x8d: ['DUP', 3, 0, 1],
  0x8e: ['DUP', 3, 0, 1],
  0x8f: ['DUP', 3, 0, 1],

  0x90: ['SWAP', 3, 0, 0],
  0x91: ['SWAP', 3, 0, 0],
  0x92: ['SWAP', 3, 0, 0],
  0x93: ['SWAP', 3, 0, 0],
  0x94: ['SWAP', 3, 0, 0],
  0x95: ['SWAP', 3, 0, 0],
  0x96: ['SWAP', 3, 0, 0],
  0x97: ['SWAP', 3, 0, 0],
  0x98: ['SWAP', 3, 0, 0],
  0x99: ['SWAP', 3, 0, 0],
  0x9a: ['SWAP', 3, 0, 0],
  0x9b: ['SWAP', 3, 0, 0],
  0x9c: ['SWAP', 3, 0, 0],
  0x9d: ['SWAP', 3, 0, 0],
  0x9e: ['SWAP', 3, 0, 0],
  0x9f: ['SWAP', 3, 0, 0],

  0xa0: ['LOG', 0, 2, 0],
  0xa1: ['LOG', 0, 3, 0],
  0xa2: ['LOG', 0, 4, 0],
  0xa3: ['LOG', 0, 5, 0],
  0xa4: ['LOG', 0, 6, 0],

  // '0xf0' range - closures
  0xf0: ['CREATE', 0, 3, 1],
  0xf1: ['CALL', 0, 7, 1],
  0xf2: ['CALLCODE', 0, 7, 1],
  0xf3: ['RETURN', 0, 2, 0],
  0xf4: ['DELEGATECALL', 0, 6, 1],

  // '0x70', range - other
  0xff: ['SELFDESTRUCT', 0, 1, 0]
}

module.exports = function (op) {
  const code = codes[op] ? codes[op] : ['INVALID', 0, 0, 0]
  let opcode = code[0]
  let number

  switch (opcode) {
    case 'LOG':
      number = op - 0xa0
      break

    case 'PUSH':
      number = op - 0x5f
      break

    case 'DUP':
      number = op - 0x7f
      break

    case 'SWAP':
      number = op - 0x8f
      break
  }

  return {
    name: opcode,
    fee: code[1],
    off: code[2],
    on: code[3],
    number: number
  }
}
