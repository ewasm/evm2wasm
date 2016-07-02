const BN = require('bn.js')
const fs = require('fs')
const opcodes = require('./opcodes.js')

// map to track dependant WASM functions
const depMap = new Map([
  ['MOD', ['ISZERO_32', 'GTE']],
  ['SDIV', ['ISZERO_32', 'GTE']],
  ['SMOD', ['ISZERO_32', 'GTE']],
  ['DIV', ['ISZERO_32', 'GTE']],
  ['EXP', ['ISZERO_32', 'MUL_256']],
  ['MUL', ['MUL_256']]
])

// compile segments
exports.compile = function (evmCode) {
  const opcodesUsed = new Set()
  const opcodesIgnore = new Set(['JUMP', 'JUMPI', 'JUMPDEST', 'STOP'])
  const initCode = '(get_local $sp)'
  let wasmCode =   initCode
  let opcodeCount = 0
  const segments = []
  let segNumber = 0

  for (let i = 0; i < evmCode.length; i++) {
    const op = opcodes(evmCode[i])
    let bytes
    switch (op.name) {
      case 'JUMP':
        wasmCode = `(set_local $sp ${wasmCode})
                    (set_local $jump_dest (i32.wrap/i64 (i64.load (i32.sub (get_local $sp) (i32.const 32)))))
                    (br $loop)`
        break
      case 'JUMPI':
        wasmCode = `(block 
                        (set_local $temp ${wasmCode})
                        (set_local $sp (i32.sub (get_local $temp) (i32.const 8)))
                        (set_local $jump_dest (get_local $temp))
                        (br_if $loop (i64.load (i32.add (get_local $sp) (i32.const 4)))))`
        break
      case 'JUMPDEST':
        segments.push([wasmCode, segNumber])
        segNumber = i
        wasmCode = initCode
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
        let q = 0
        for (; q < bytes.length; q += 8) {
          const int64 = bytes2int64(bytes.slice(q, q + 8))
          wasmCode = `(i64.const ${int64})` + wasmCode
        }
        // padd the remaining of the word with 0
        for (; q < 32; q += 8) {
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
      case 'STOP':
        wasmCode = `${wasmCode} (br $done)`
        break
    }
    if (!opcodesIgnore.has(op.name)) {
      wasmCode = `(call $${op.name} ${wasmCode})`
      opcodesUsed.add(op.name)
    }
    opcodeCount++
  }
  if (wasmCode !== '') {
    segments.push([wasmCode, segNumber])
  }
  const mainFunc = '(start $main)' + assmebleSegments(segments)
  const funcMap = exports.resolveFunctions(opcodesUsed)
  funcMap.push(mainFunc)
  return exports.buildModule(funcMap)
}

function compileSegment (segment) {
   
}

// add an op as this contract depends on
function addOpDep (opset, op) {
  opset.add(opset)
  const deps = depMap.get(op)
  if (deps) {
    deps.forEach((dep) => {
      addOpDep(opset, dep)
    })
  }
}

function assmebleSegments (segments) {
  let wasm = buildJumpMap(segments)

  segments.forEach((seg, index) => {
    wasm = `(block $${index + 1} 
             ${wasm}
             ${seg[0]})`
  })
  return `(func $main 
           (local $sp i32) 
           (local $temp i32) 
           (local $jump_dest i32)
           (loop $done $loop
            ${wasm}))`
}

function buildJumpMap (segments) {
  let wasm = '(unreachable)'
  let brTable = '(block $0 (br_table'

  segments.forEach((seg, index) => {
    brTable += ' $' + index
    wasm = `(if (i32.eq (get_local $jump_dest) (i32.const ${seg[1]}))
                (then (i32.const ${index}))
                (else ${wasm}))`
  })

  brTable += wasm + '))'
  return brTable
}

// converts 8 bytes into a int 64
function bytes2int64 (bytes) {
  return new BN(bytes).fromTwos(64).toString()
}

exports.resolveFunctions = function resolveFunctions (funcSet, dir = '/wasm/') {
  let funcs = []
  for (let func of funcSet) {
    const wastPath = __dirname + dir + func + '.wast'
    const wast = fs.readFileSync(wastPath)
    funcs.push(wast.toString())
    const depFuncs = depMap.get(func)
    if (depFuncs) {
      funcs = funcs.concat(resolveFunctions(depFuncs, dir))
    }
  }
  return funcs
}

exports.buildModule = function buildModule (funcs, imports=[], exports=[]) {
  let funcStr = ''
  for (let func of funcs) {
    funcStr += func
  }
  for (let exprt of exports) {
    funcStr += `(export "${exprt}" $${exprt})`
  }
  return `(module
          (memory 1 1)
          (export "a" memory)
           ${funcStr}
          )`
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
