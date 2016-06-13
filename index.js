const BN = require('bn.js')
const opcodes = require('./opcodes.js')

// compile segments
module.exports = function (evmCode) {
  const initCode = '(get_local $sp)'
  let wasmCode = initCode
  let opcodeCount = 0
  const segments = []
  for (let i = 0; i < evmCode.length; i++) {
    const op = opcodes(evmCode[i])
    let bytes
    switch (op.name) {
      case 'JUMP':
        wasmCode = `(set_local $temp ${wasmCode})
                        (set_local $sp i32.sub (get_local $temp) (i32.const 4))
                        (set_local $jump_loc (get_local $temp))
                        (br $loop)`
        break
      case 'JUMPI':
        wasmCode = `(block 
                        (set_local $temp ${wasmCode})
                        (set_local $sp i32.sub (get_local $temp) (i32.const 8))
                        (set_local $jump_loc (get_local $temp))
                        (br_if $loop (i64.load (i32.add (get_local $sp) (i32.const 4)))))`
        break
      case 'JUMPDEST':
        segments.push(wasmCode)
        wasmCode = ''
        break
      case 'LOG':
        bytes = evmCode.slice(i, i + op.number * 8)
        for (let i = 0; i < bytes.length; i += 8) {
          const int64 = bytes2int64(bytes.slice(i, i + 8))
          wasmCode = `(i64.const ${int64})` + wasmCode
        }
        i += op.number
        break
      case 'PUSH':
        bytes = evmCode.slice(i, i + op.number * 8)
        for (let i = 0; i < bytes.length; i += 8) {
          const int64 = bytes2int64(bytes.slice(i, i + 8))
          wasmCode = `(i64.const ${int64})` + wasmCode
        }
        // padd the remained of the word with 0
        for (let i = 0; i < 32 - bytes.length; i += 8) {
          wasmCode = '(i64.const 0)' + wasmCode
        }
        i += op.number
        break
      case 'DUP':
        wasmCode = `(i64.const ${op.number})` + wasmCode
        break
      case 'SWAP':
        wasmCode = `(i64.const ${op.number})` + wasmCode
        break
    }
    wasmCode = `(call $${op.name} ${wasmCode})`
    opcodeCount++
  }
  if (wasmCode !== '') {
    segments.push(wasmCode)
  }
  return assmebleSegments(segments)
}

function assmebleSegments (segments) {
  return segments[0]
}

// converts 8 bytes into a int 64
function bytes2int64(bytes) {
  return new BN(bytes).fromTwos(64).toString()
}
// remap code hashes
// pull original code; if code is not wasm try to convert it. Transpiler will 
// need to be written in wasm
// TRADE OFF 
//  if you have polifilly 
//
// transcompiling create code; can be done at runtime.
// how to store old code? just use prefix
// store the old code in mem storage. 
//  how to protect?
//   use a longer or shorter path then the current contracts have access to
//   transcompiler contract
//    which then get the code and run its
//    extra cost first time calling it
