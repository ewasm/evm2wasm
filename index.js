const BN = require('bn.js')
const ethUtil = require('ethereumjs-util')
const fs = require('fs')
const cp = require('child_process')
const opcodes = require('./opcodes.js')
const path = require('path')

// map to track dependent WASM functions
const depMap = new Map([
  ['MOD', ['ISZERO_32', 'GTE']],
  ['ADDMOD', ['MOD', 'ADD']],
  ['SDIV', ['ISZERO_32', 'GTE']],
  ['SMOD', ['ISZERO_32', 'GTE']],
  ['DIV', ['ISZERO_32', 'GTE']],
  ['EXP', ['ISZERO_32', 'MUL_256']],
  ['MUL', ['MUL_256']],
  ['ISZERO', ['ISZERO_32']],
  ['MSTORE', ['MEMUSEGAS']],
  ['MSTORE8', ['MEMUSEGAS']]
])

// this is used to generate the module's import table
const interfaceImportMap = {
  'storageStore': {
    'inputs': [ 'i32', 'i32' ]
  },
  'storageLoad': {
    'inputs': ['i32', 'i32']
  },
  'useGas': {
    'inputs': [ 'i32' ]
  },
  'return': {
    'inputs': [ 'i32', 'i32' ]
  },
  'getBlockHash': {
    'inputs': ['i32', 'i32']
  },
  'getCaller': {
    'inputs': [ 'i32' ]
  },
  'getAddress': {
    'inputs': [ 'i32' ]
  },
  'getBlockDifficulty': {
    'inputs': [ 'i32' ]
  },
  'getBlockCoinbase': {
    'inputs': [ 'i32' ]
  },
  'getBlockGasLimit': {
    'output': 'i32'
  },
  'getBlockNumber': {
    'output': 'i32'
  },
  'getBlockTimestamp': {
    'output': 'i32'
  },
  'getCallDataSize': {
    'output': 'i32'
  },
  'callDataCopy': {
    'inputs': ['i32', 'i32', 'i32']
  },
  'callDataCopy256': {
    'inputs': ['i32', 'i32']
  },
  'getExternalCodeSize': {
    'inputs': ['i32'],
    'output': 'i32'
  }
}

// compiles evmCode to wasm in the binary format
// @param {Array} evmCode
// @param {Boolean}  stackTrace set to true if you want a stacktrace
exports.compile = function (evmCode, stackTrace = false) {
  const wast = exports.compileEVM(evmCode, stackTrace)
  return exports.compileWAST(wast)
}

// compiles wasm text format to binary
// @param {String} wast
// @return {buffer}
exports.compileWAST = function (wast) {
  fs.writeFileSync('temp.wast', wast)
  cp.execSync(`${__dirname}/tools/sexpr-wasm-prototype/out/sexpr-wasm ./temp.wast -o ./temp.wasm`)
  return fs.readFileSync('./temp.wasm')
}

// Transcompiles EVM code to ewasm in the sexpression text format. The EVM code
// is broken into segments and each instruction in those segments is replaced
// with a `call` to wasm function that does the equivalent operation. Each
// opcode function takes in and returns the stack pointer.
//
// Segments are sections of EVM code in between flow control
// opcodes (JUMPI. JUMP).
// All segments start at
// * the beginning for EVM code
// * a GAS opcode (TODO)
// * a JUMPDEST opcode
// * After a JUMPI opcode
// @param {Integer[]} evmCode the evm byte code
// @param {Boolean} stackTrace if `true` generates a stack trace
// @return {String}
exports.compileEVM = function (evmCode, stackTrace) {
  // this keep track of the opcode we have found so far. This will be used to
  // to figure out what .wast files to include
  const opcodesUsed = new Set()
  // some opcodes don't have wast files
  const opcodesIgnore = new Set(['JUMP', 'JUMPI', 'JUMPDEST', 'STOP', 'RETURN'])
  // this is the wasm code that each segment starts with
  const initCode = '(get_local $sp)'
  // an array of found segments
  const segments = []
  // the transcompiled EVM code
  let wasmCode = initCode
  // used to translate the local in EVM of JUMPDEST to a wasm block label
  let jumpDestNum = 0
  // keeps track of the gas that each section uses
  let gasCount = 0
  // used for pruning dead code
  let jumpFound = false

  for (let i = 0; i < evmCode.length; i++) {
    const opint = evmCode[i]
    const op = opcodes(opint)
    let bytes
    gasCount += op.fee
    switch (op.name) {
      case 'JUMP':
        jumpFound = true
        wasmCode = `;; jump
                      (set_local $sp ${wasmCode})
                      (set_local $jump_dest (i32.load (get_local $sp)))
                      (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))
                      (br $loop)`
        i = findNextJumpDest(evmCode, i)
        break
      case 'JUMPI':
        jumpFound = true
        wasmCode = `(block
                    (set_local $sp ${wasmCode})
                    (set_local $jump_dest (i32.load (get_local $sp)))
                    (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))
                    (set_local $scratch (i64.or
                      (i64.load (i32.add (get_local $sp) (i32.const 0)))
                      (i64.or
                        (i64.load (i32.add (get_local $sp) (i32.const 8)))
                        (i64.or
                          (i64.load (i32.add (get_local $sp) (i32.const 16)))
                          (i64.load (i32.add (get_local $sp) (i32.const 24)))
                        )
                      )
                    ))
                    (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))
                    (br_if $loop (i32.eqz (i64.eqz (get_local $scratch))))
                    (get_local $sp)
                    )`
        addSegement(false)
        wasmCode = initCode
        break
      case 'JUMPDEST':
        addSegement()
        jumpDestNum = i
        wasmCode = initCode
        gasCount++
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
        bytes = ethUtil.setLength(evmCode.slice(i, i += op.number), 32)
        const bytesRounded = Math.ceil(op.number / 8)
        let push = ''
        let q = 0
        // pad the remaining of the word with 0
        for (; q < 4 - bytesRounded; q++) {
          push = '(i64.const 0)' + push
        }

        for (; q < 4; q++) {
          const int64 = bytes2int64(bytes.slice(q * 8, q * 8 + 8))
          push = push + `(i64.const ${int64})`
        }

        wasmCode = push + wasmCode

        i--
        break
      case 'DUP':
        // adds the number on the stack to DUP
        wasmCode = `(i32.const ${op.number - 1})` + wasmCode
        break
      case 'SWAP':
        // adds the number on the stack to SWAP
        wasmCode = `(i32.const ${op.number - 1})` + wasmCode
        break
      case 'STOP':
        wasmCode = `${wasmCode} (br $done)`
        if (jumpFound) {
          i = findNextJumpDest(evmCode, i)
        } else {
          i = evmCode.length
        }
        break
      case 'RETURN':
        wasmCode = `\n(call $${op.name} ${wasmCode}) (br $done)`
        opcodesUsed.add(op.name)
        if (jumpFound) {
          i = findNextJumpDest(evmCode, i)
        } else {
          i = evmCode.length
        }
        break
      case 'INVALID':
        throw new Error('Invalid opcode ' + evmCode[i].toString(16))
    }
    if (!opcodesIgnore.has(op.name)) {
      if (stackTrace) {
        // creates a stack trace
        wasmCode = `\n(call_import $stackTrace (call $${op.name} ${wasmCode}) (i32.const ${opint} ))`
      } else {
        wasmCode = `\n(call $${op.name} ${wasmCode})`
      }
      opcodesUsed.add(op.name)
    }
  }

  if (wasmCode !== '') {
    addSegement()
  }

  let mainFunc = '(export "main" $main)' + assmebleSegments(segments)

  // import stack trace function
  if (stackTrace) {
    mainFunc = '(import $stackTrace "debug" "evmStackTrace" (param i32 i32) (result i32))' + mainFunc
  }

  const funcMap = exports.resolveFunctions(opcodesUsed)
  funcMap.push(mainFunc)
  return exports.buildModule(funcMap)

  function addSegement (isJumpDest = true) {
    wasmCode = `(call_import $useGas (i32.const ${gasCount})) ${wasmCode}`
    gasCount = 0
    segments.push([wasmCode, jumpDestNum, isJumpDest])
  }
}

// given an array for segments builds a wasm module from those segments
// @param {Array} segments
// @return {String}
function assmebleSegments (segments) {
  let wasm = buildJumpMap(segments)
  let jumpSegOffset = 0

  segments.forEach((seg, index) => {
    if (seg[2]) {
      wasm = `(block $${index + 1 - jumpSegOffset} 
               ${wasm}
               ${seg[0]})`
    } else {
      jumpSegOffset++
      wasm = `${wasm}
               ${seg[0]}`
    }
  })
  return `(func $main 
           (local $scratch i64)
           (local $sp i32) 
           (local $jump_dest i32)
           (set_local $sp (i32.const -32)) 
           (loop $done $loop
            ${wasm}))`
}

// Builds the Jump map, which maps EVM jump location to a block label
// @param {Array} segments
// @return {String}
function buildJumpMap (segments) {
  let wasm = '(unreachable)'
  let brTable = '(block $0 (br_table'

  segments.filter((seg) => seg[2]).forEach((seg, index) => {
    brTable += ' $' + index
    wasm = `(if (i32.eq (get_local $jump_dest) (i32.const ${seg[1]}))
                  (then (i32.const ${index}))
                  (else ${wasm}))`
  })

  brTable += wasm + '))'
  return brTable
}

// returns the index of the next jump destination opcode in given EVM code in an
// array and a starting index
// @param {Array} evmCode
// @param {Integer} index
// @return {Integer}
function findNextJumpDest (evmCode, i) {
  for (; i < evmCode.length; i++) {
    const opint = evmCode[i]
    const op = opcodes(opint)
    switch (op.name) {
      case 'PUSH':
        // skip add how many bytes where pushed
        i += op.number
        break
      case 'JUMPDEST':
        return --i
    }
  }
  return --i
}

// converts 8 bytes into a int 64
// @param {Integer}
// @return {String}
function bytes2int64 (bytes) {
  return new BN(bytes).fromTwos(64).toString()
}

// Ensure that dependencies are only imported once (use the Set)
// @param {Set} funcSet a set of wasm function that need to be linked to their
// dependencies
// @return {Set}
exports.resolveFunctionDeps = function resolveFunctionDeps (funcSet) {
  let funcs = funcSet
  for (let func of funcSet) {
    const deps = depMap.get(func)
    if (deps) {
      for (var dep of deps) {
        funcs.add(dep)
      }
    }
  }
  return funcs
}

// given a set of wasm function this return an array for wasm equivalents
// @param {Set} funcSet
// @param {String} dir
// @return {Array}
exports.resolveFunctions = function resolveFunctions (funcSet, dir = '/wasm/') {
  let funcs = []
  for (let func of exports.resolveFunctionDeps(funcSet)) {
    const wastPath = path.join(__dirname, dir, func) + '.wast'
    try {
      const wast = fs.readFileSync(wastPath)
      funcs.push(wast.toString())
    } catch (e) {
      // FIXME: remove this once every opcode is implemented
      //        (though it should not cause any issues)
      console.error('Inserting MISSING opcode', func)
      funcs.push(`(func $${func} (param $sp i32) (result i32) (unreachable))`)
    }
  }
  return funcs
}

// builds the import table
// @return {String}
exports.buildInterfaceImports = function () {
  let importStr = ''

  Object.keys(interfaceImportMap).forEach((key) => {
    let options = interfaceImportMap[key]

    importStr += `(import $${key} "ethereum" "${key}"`

    if (options.inputs) {
      importStr += ' (param '
      for (let input of options.inputs) {
        importStr += `${input} `
      }
      importStr += ')'
    }

    if (options.output) {
      importStr += ` (result ${options.output})`
    }

    importStr += `)\n`
  })

  return importStr
}

// builds a wasm module
// @param {Array} funcs the function to include in the module
// @param {Array} imports the imports for the module's import table
// @param {Array} exports the exports for the module's export table
// @return {String}
exports.buildModule = function buildModule (funcs, imports = [], exports = []) {
  let funcStr = ''
  for (let func of funcs) {
    funcStr += func
  }
  for (let exprt of exports) {
    funcStr += `(export "${exprt}" $${exprt})`
  }
  let importStr = this.buildInterfaceImports()
  return `(module
          ${importStr}
          (memory 1)
          (export "memory" memory)
            ${funcStr}
          )`
}
