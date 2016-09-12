const BN = require('bn.js')
const ethUtil = require('ethereumjs-util')
const fs = require('fs')
const cp = require('child_process')
const opcodes = require('./opcodes.js')
const wastFiles = require('./wasm/wast.json')

// map to track dependent WASM functions
const depMap = new Map([
  ['MOD', ['iszero_32', 'gte_256']],
  ['ADDMOD', ['MOD', 'ADD', 'mod_320', 'iszero_320', 'gte_320']],
  ['MULMOD', ['mod_512', 'iszero_512', 'gte_512']],
  ['SDIV', ['iszero_32', 'gte_256']],
  ['SMOD', ['iszero_32', 'gte_256']],
  ['DIV', ['iszero_32', 'gte_256']],
  ['EXP', ['iszero_32', 'mul_256']],
  ['MUL', ['mul_256']],
  ['ISZERO', ['iszero_32']],
  ['MSTORE', ['memusegas', 'bswap_m256', 'bswap_i64', 'check_overflow']],
  ['MLOAD', ['memusegas', 'bswap_m256', 'bswap_i64', 'check_overflow']],
  ['MSTORE8', ['memusegas', 'check_overflow']],
  ['CODECOPY', ['memusegas', 'check_overflow', 'memset']],
  ['CALLDATALOAD', ['bswap_m256', 'bswap_i64', 'check_overflow']],
  ['CALLDATACOPY', ['memusegas', 'check_overflow', 'memset']],
  ['EXTCODECOPY', ['memusegas', 'check_overflow', 'memset']],
  ['LOG', ['memusegas', 'check_overflow']],
  ['BLOCKHASH', ['check_overflow']],
  ['SHA3', ['memusegas', 'bswap_m256', 'bswap_i64', 'check_overflow', 'keccak', 'memcpy', 'memset']],
  ['CALL', ['memusegas', 'check_overflow', 'memset']],
  ['CALLCODE', ['memusegas', 'check_overflow', 'memset']],
  ['CREATE', ['memusegas', 'check_overflow']],
  ['RETURN', ['memusegas', 'check_overflow']]
])

/**
 * compiles evmCode to wasm in the binary format
 * @memberof exports
 * @param {Array} evmCode
 * @param {Object} opts
 * @param {boolean} opts.stackTrace if `true` generates a stack trace
 * @param {boolean} opts.pprint if `true` pretty prints the sexpressions
 * @param {boolean} opts.inlineOps if `true` inlines the EVM1 operations
 * @return {string}
 */
exports.compile = function (evmCode, opts = {
  'stackTrace': false,
  'pprint': false,
  'inlineOps': true
}) {
  const wast = exports.compileEVM(evmCode, opts)
  return exports.compileWAST(wast)
}

/**
 * compiles wasm text format to binary
 * @param {string} wast
 * @return {buffer}
 */
exports.compileWAST = function (wast) {
  fs.writeFileSync('temp.wast', wast)
  cp.execSync(`${__dirname}/tools/sexpr-wasm-prototype/out/sexpr-wasm ./temp.wast -o ./temp.wasm`)
  return fs.readFileSync('./temp.wasm')
}

/**
 * Transcompiles EVM code to ewasm in the sexpression text format. The EVM code
 * is broken into segments and each instruction in those segments is replaced
 * with a `call` to wasm function that does the equivalent operation. Each
 * opcode function takes in and returns the stack pointer.
 *
 * Segments are sections of EVM code in between flow control
 * opcodes (JUMPI. JUMP).
 * All segments start at
 * * the beginning for EVM code
 * * a GAS opcode
 * * a JUMPDEST opcode
 * * After a JUMPI opcode
 * @method compileEVM
 * @param {Integer} evmCode the evm byte code
 * @param {Object} opts
 * @param {boolean} opts.stackTrace if `true` generates a stack trace
 * @param {boolean} opts.pprint if `true` pretty prints the sexpressions
 * @param {boolean} opts.inlineOps if `true` inlines the EVM1 operations
 * @return {string}
 */
exports.compileEVM = function (evmCode, opts = {
  'stackTrace': false,
  'pprint': false,
  'inlineOps': true
}) {
  // this keep track of the opcode we have found so far. This will be used to
  // to figure out what .wast files to include
  const opcodesUsed = new Set()
  const ignoredOps = new Set(['JUMP', 'JUMPI', 'JUMPDEST', 'POP', 'STOP', 'INVALID'])
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
        opcodesUsed.add('check_overflow')
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
        opcodesUsed.add('check_overflow')
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
        wasmCode = `${wasmCode} (call $${op.name} (get_local $sp))`
        addMetering()
        break
      case 'LOG':
        wasmCode = `${wasmCode} (call $${op.name} (i32.const ${op.number}) (get_local $sp))`
        break
      case 'DUP':
      case 'SWAP':
        // adds the number on the stack to SWAP
        wasmCode = `${wasmCode} (call $${op.name} (i32.const ${op.number - 1}) (get_local $sp)) `
        break
      case 'PC':
        wasmCode = `${wasmCode} (call $${op.name} (i32.const ${i}) (get_local $sp))`
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

        wasmCode = `${wasmCode} (call $${op.name} ${push} (get_local $sp))`
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
      case 'SUICIDE':
      case 'RETURN':
        wasmCode = `${wasmCode} (call $${op.name} (get_local $sp)) (br $done)`
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
        wasmCode = `${wasmCode} (call $${op.name} (get_local $sp))`
    }

    if (!ignoredOps.has(op.name)) {
      opcodesUsed.add(op.name)
    }

    const stackDeta = op.on - op.off
    // update the stack pointer
    if (stackDeta !== 0) {
      wasmCode = `${wasmCode} (set_local $sp (i32.add (get_local $sp) (i32.const ${stackDeta * 32})))`
    }

    // creates a stack trace
    if (opts.stackTrace) {
      wasmCode = `${wasmCode} (call_import $stackTrace (get_local $sp) (i32.const ${opint}))`
    }
  }
  addStackCheck()
  addMetering()
  jumpSegments.push([segment, jumpDestNum])

  let mainFunc = assmebleSegments(jumpSegments)

  // import stack trace function
  if (opts.stackTrace) {
    mainFunc = '(import $stackTrace "debug" "evmStackTrace" (param i32 i32) (result i32))' + mainFunc
  }

  let funcMap = []
  if (opts.inlineOps) {
    funcMap = exports.resolveFunctions(opcodesUsed)
  }

  funcMap.push(mainFunc)
  wasmCode = exports.buildModule(funcMap)
  if (opts.pprint) {
    wasmCode = pprint(wasmCode)
  }
  return wasmCode

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
  return `
    (export "main" $main)
      (func $main 
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

/**
 * Ensure that dependencies are only imported once (use the Set)
 * @param {Set} funcSet a set of wasm function that need to be linked to their dependencies
 * @return {Set}
 */
exports.resolveFunctionDeps = function (funcSet) {
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

/**
 * given a Set of wasm function this return an array for wasm equivalents
 * @param {Set} funcSet
 * @return {Array}
 */
exports.resolveFunctions = function (funcSet) {
  let funcs = []
  for (let func of exports.resolveFunctionDeps(funcSet)) {
    funcs.push(wastFiles[func + '.wast'])
  }
  return funcs
}

/**
 * builds a wasm module
 * @param {Array} funcs the function to include in the module
 * @param {Array} imports the imports for the module's import table
 * @return {string}
 */
exports.buildModule = function (funcs, imports = [], exports = []) {
  let funcStr = ''
  for (let func of funcs) {
    funcStr += func
  }
  for (let exprt of exports) {
    funcStr += `(export "${exprt}" $${exprt})`
  }
  return `(module
          (import $useGas "ethereum" "useGas" (param i32))
          (memory 1)
          (export "memory" memory)
            ${funcStr}
          )`
}

// a s-expression pretty print function
// TODO: handle comments
function pprint (sexp) {
  // removes all newlins
  sexp = sexp.replace(/[^\x20-\x7E]/gmi, '').split('(')
  let numSpaces = 0
  for (let i in sexp) {
    let statement = sexp[i]
    statement = statement.split(')').map(a => a.trim())
    let length = statement.length
    statement = statement.join(')')
    if (statement !== '') {
      statement = '(' + statement
      statement = '\n' + ' '.repeat(numSpaces * 2) + statement
      numSpaces += -length + 2
    }
    sexp[i] = statement
  }
  return sexp.join('')
}
