const BN = require('bn.js')
const fs = require('fs')
const opcodes = require('./opcodes.js')

// compile segments
module.exports = function compile (evmCode) {
  const initCode = '(get_local $sp)'
  const opcodesUsed = new Set()
  let wasmCode = initCode
  let opcodeCount = 0
  const segments = []
  let segNumber = 0
  for (let i = 0; i < evmCode.length; i++) {
    const op = opcodes(evmCode[i])
    let bytes
    switch (op.name) {
      case 'JUMP':
        wasmCode = `(set_local $temp ${wasmCode})
                        (set_local $sp i32.sub (get_local $temp) (i32.const 4))
                        (set_local $jump_dest (get_local $temp))
                        (br $loop)`
        break
      case 'JUMPI':
        wasmCode = `(block 
                        (set_local $temp ${wasmCode})
                        (set_local $sp i32.sub (get_local $temp) (i32.const 8))
                        (set_local $jump_dest (get_local $temp))
                        (br_if $loop (i64.load (i32.add (get_local $sp) (i32.const 4)))))`
        break
      case 'JUMPDEST':
        segments.push([wasmCode, segNumber])
        segNumber = i
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
        i++
        bytes = evmCode.slice(i, i + op.number)
        // console.log(bytes);
        for (let i = 0; i < bytes.length; i += 8) {
          const int64 = bytes2int64(bytes.slice(i, i + 8))
          wasmCode = `(i64.const ${int64})` + wasmCode
        }
        // padd the remaining of the word with 0
        for (let i = 0; i < 32 - bytes.length; i += 8) {
          wasmCode = '(i64.const 0)' + wasmCode
        }
        i += op.number - 1
        break
      case 'DUP':
        wasmCode = `(i64.const ${op.number})` + wasmCode
        break
      case 'SWAP':
        wasmCode = `(i64.const ${op.number})` + wasmCode
        break
    }
    wasmCode = `(call $${op.name} ${wasmCode})`
    if (op.name.slice(4) !== 'JUMP') {
      opcodesUsed.add(op.name)
    }
    opcodeCount++
  }
  if (wasmCode !== '') {
    segments.push([wasmCode, segNumber])
  }
  const mainFunc = assmebleSegments(segments)
  console.log(mainFunc)
  const funcMap = resolveFuncs(opcodesUsed)
  funcMap.set('main', mainFunc)
  return assembleFunctions(funcMap)
}

function assmebleSegments (segments) {
  let wasm = buildJumpMap(segments)

  segments.forEach((seg) => {
    wasm = `(block
             ${wasm}
             ${seg[0]})`
  })
  return `(func $main 
           (local $sp i32) 
           (local $jump_dest i32)
           ${wasm})`
}

function buildJumpMap (segments) {
  let wasm = '(unreachable)'
  let brTable = '(br_table'

  segments.forEach((seg, index) => {
    brTable += ' ' + index.toString()
    wasm = `(if (i32.eq (get_local $jump_dest) (i32.const ${seg[1]})
                (then (i32.const ${index}))
                (else ${wasm})))`
  })

  brTable += wasm + ')'
  return brTable
}

// converts 8 bytes into a int 64
function bytes2int64 (bytes) {
  return new BN(bytes).fromTwos(64).toString()
}

function resolveFuncs (funcs, dir = '/wasm/') {
  const funcMap = new Map()
  for (let func of funcs) {
    const wastPath =  __dirname + dir + func + '.wast'
    const wast = fs.readFileSync(wastPath)
    funcMap.set(func, wast.toString())
  }
  return funcMap
}

function assembleFunctions (funcs, imports, exports) {
  let funcStr = ''
  for (let func of funcs) {
    funcStr += func[1]
  }
  return `(module ${funcStr})`
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
