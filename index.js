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
  ['MSTORE', ['MEMUSEGAS', 'swap_word', 'check_overflow']],
  ['MLOAD', ['MEMUSEGAS', 'swap_word', 'check_overflow']],
  ['MSTORE8', ['MEMUSEGAS', 'check_overflow']],
  ['CODECOPY', ['MEMUSEGAS', 'check_overflow', 'zero_mem']],
  ['CALLDATALOAD', ['swap_word', 'check_overflow']],
  ['CALLDATACOPY', ['MEMUSEGAS', 'check_overflow', 'zero_mem']],
  ['EXTCODECOPY', ['MEMUSEGAS', 'check_overflow', 'zero_mem']],
  ['LOG', ['MEMUSEGAS', 'check_overflow']],
  ['JUMPI', ['check_overflow']],
  ['JUMP', ['check_overflow']],
  ['SHA3', ['MEMUSEGAS', 'check_overflow']]
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
  'getTxOrigin': {
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
  'getGasLeft': {
    'output': 'i64'
  },
  'codeCopy': {
    'inputs': ['i32', 'i32', 'i32']
  },
  'getCodeSize': {
    'output': 'i32'
  },
  'getTxGasPrice': {
    'output': 'i32'
  },
  'callDataCopy': {
    'inputs': ['i32', 'i32', 'i32']
  },
  'callDataCopy256': {
    'inputs': ['i32', 'i32']
  },
  'getBalance': {
    'inputs': ['i32', 'i32']
  },
  'getCallValue': {
    'inputs': ['i32']
  },
  'getExternalCodeSize': {
    'inputs': ['i32'],
    'output': 'i32'
  },
  'externalCodeCopy': {
    'inputs': ['i32', 'i32', 'i32', 'i32'],
    'output': 'i32'
  },
  'log': {
    'inputs': ['i32', 'i32', 'i32', 'i32', 'i32', 'i32', 'i32']
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
// * a GAS opcode
// * a JUMPDEST opcode
// * After a JUMPI opcode
// @param {Integer[]} evmCode the evm byte code
// @param {Boolean} stackTrace if `true` generates a stack trace
// @return {String}
exports.compileEVM = function (evmCode, stackTrace) {
  // this keep track of the opcode we have found so far. This will be used to
  // to figure out what .wast files to include
  const opcodesUsed = new Set()
  // an array of found segments
  const jumpSegments = []
  // the transcompiled EVM code
  let wasmCode = ''
  let segment = ''
  // used to translate the local in EVM of JUMPDEST to a wasm block label
  let jumpDestNum = -1
  // keeps track of the gas that each section uses
  let gasCount = 0
  // used for pruning dead code
  let jumpFound = false
  // the accumlitive stack difference for the current segmnet
  let segmentStackDeta = 0
  let segmentStackHigh = 0
  let segmentStackLow = 0

  for (let i = 0; i < evmCode.length; i++) {
    const opint = evmCode[i]
    const op = opcodes(opint)
    let bytes
    gasCount += op.fee

    segmentStackDeta += op.on
    if (segmentStackDeta > segmentStackHigh) {
      segmentStackHigh = segmentStackDeta
    }

    segmentStackDeta -= op.off
    if (segmentStackDeta < segmentStackLow) {
      segmentStackLow = segmentStackDeta
    }

    switch (op.name) {
      case 'JUMP':
        jumpFound = true
        wasmCode = `${wasmCode}
                    ;; jump
                      (set_local $jump_dest (call $check_overflow 
                                             (i64.load (get_local $sp))
                                             (i64.load (i32.add (get_local $sp) (i32.const 8)))
                                             (i64.load (i32.add (get_local $sp) (i32.const 16)))
                                             (i64.load (i32.add (get_local $sp) (i32.const 24)))))
                      (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))
                      (br $loop)`
        i = findNextJumpDest(evmCode, i)
        break
      case 'JUMPI':
        jumpFound = true
        wasmCode = `${wasmCode}
                    (set_local $jump_dest (call $check_overflow 
                                             (i64.load (get_local $sp))
                                             (i64.load (i32.add (get_local $sp) (i32.const 8)))
                                             (i64.load (i32.add (get_local $sp) (i32.const 16)))
                                             (i64.load (i32.add (get_local $sp) (i32.const 24)))))

                    (set_local $sp (i32.sub (get_local $sp) (i32.const 64)))
                    (br_if $loop (i32.eqz (i64.eqz (i64.or
                      (i64.load (i32.add (get_local $sp) (i32.const 32)))
                      (i64.or
                        (i64.load (i32.add (get_local $sp) (i32.const 40)))
                        (i64.or
                          (i64.load (i32.add (get_local $sp) (i32.const 48)))
                          (i64.load (i32.add (get_local $sp) (i32.const 56)))
                        )
                      )
                    ))))`
        addStackCheck()
        addMetering()
        break
      case 'JUMPDEST':
        addStackCheck()
        addMetering()
        jumpSegments.push([segment, jumpDestNum])
        segment = ''
        jumpDestNum = i
        gasCount = 1
        break
      case 'GAS':
        wasmCode = `${wasmCode} \n (call $${op.name} (get_local $sp))`
        addMetering()
        break
      case 'LOG':
        wasmCode = `${wasmCode} \n (call $${op.name} (i32.const ${op.number}) (get_local $sp))`
        break
      case 'DUP':
      case 'SWAP':
        // adds the number on the stack to SWAP
        wasmCode = `${wasmCode} \n (call $${op.name} (i32.const ${op.number - 1}) (get_local $sp)) `
        break
      case 'PC':
        wasmCode = `${wasmCode} \n (call $${op.name} (i32.const ${i}) (get_local $sp))`
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

        wasmCode = `${wasmCode} \n (call $${op.name} ${push} (get_local $sp))`
        i--
        break
      case 'POP':
        // do nothing
        break
      case 'STOP':
        wasmCode = `${wasmCode} (br $done)`
        if (jumpFound) {
          i = findNextJumpDest(evmCode, i)
        } else {
          // the rest is dead code
          i = evmCode.length
        }
        break
      case 'RETURN':
        wasmCode = `${wasmCode} \n (call $${op.name} (get_local $sp)) (br $done)`
        if (jumpFound) {
          i = findNextJumpDest(evmCode, i)
        } else {
          // the rest is dead code
          i = evmCode.length
        }
        break
      case 'INVALID':
        wasmCode = '(unreachable)'
        i = findNextJumpDest(evmCode, i)
        break
      default:
        wasmCode = `${wasmCode} \n  (call $${op.name} (get_local $sp))`
    }

    opcodesUsed.add(op.name)

    const stackDeta = op.on - op.off
    // update the stack pointer
    if (stackDeta !== 0) {
      wasmCode = `${wasmCode} (set_local $sp (i32.add (get_local $sp) (i32.const ${stackDeta * 32})))`
    }

    // creates a stack trace
    if (stackTrace) {
      wasmCode = `${wasmCode} \n (call_import $stackTrace (get_local $sp) (i32.const ${opint}))`
    }
  }
  addStackCheck()
  addMetering()
  jumpSegments.push([segment, jumpDestNum])

  let mainFunc = '(export "main" $main)' + assmebleSegments(jumpSegments)

  // import stack trace function
  if (stackTrace) {
    mainFunc = '(import $stackTrace "debug" "evmStackTrace" (param i32 i32) (result i32))' + mainFunc
  }

  const funcMap = exports.resolveFunctions(opcodesUsed)
  funcMap.push(mainFunc)
  return exports.buildModule(funcMap)

  // add a metering statment at the beginning of a segment
  function addMetering () {
    segment = `${segment} (call_import $useGas (i32.const ${gasCount})) ${wasmCode}`
    wasmCode = ''
    gasCount = 0
  }

  // adds stack height checks to the beginning of a segment
  function addStackCheck () {
    let check = ''
    if (segmentStackHigh !== 0) {
      check = `(if (i32.gt_s (get_local $sp) (i32.const ${(1023 - segmentStackHigh) * 32})) 
                 (then (unreachable)))`
    }
    if (segmentStackLow !== 0) {
      check += `(if (i32.lt_s (get_local $sp) (i32.const ${-segmentStackLow * 32 - 32})) 
                  (then (unreachable)))`
    }
    wasmCode = check + wasmCode
    segmentStackHigh = 0
    segmentStackLow = 0
    segmentStackDeta = 0
  }
}

// given an array for segments builds a wasm module from those segments
// @param {Array} segments
// @return {String}
function assmebleSegments (segments) {
  let wasm = buildJumpMap(segments)
  let jumpSegOffset = 0

  segments.forEach((seg, index) => {
    // if its a jump
    wasm = `(block $${index + 1 - jumpSegOffset} 
               ${wasm}
               ${seg[0]})`
  })
  return `(func $main 
           (local $sp i32) 
           (local $jump_dest i32)
           (set_local $sp (i32.const -32)) 
           (set_local $jump_dest (i32.const -1)) 
           (loop $done $loop
            ${wasm}))`
}

// Builds the Jump map, which maps EVM jump location to a block label
// @param {Array} segments
// @return {String}
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
