const BN = require('bn.js')
const ethUtil = require('ethereumjs-util')
const fs = require('fs')
const cp = require('child_process')
const opcodes = require('./opcodes.js')
const wastFiles = require('./wasm/wast.json')

// map to track dependent WASM functions
// TODO remove bswaps
const depMap = new Map([
  ['callback_256', ['bswap_m256']],
  ['callback_128', ['bswap_m128']],
  ['bswap_m256', ['bswap_i64']],
  ['bswap_m128', ['bswap_i64']],
  ['bswap_m160', ['bswap_i64', 'bswap_i32']],
  ['keccak', ['memcpy', 'memset']],
  ['mod_320', ['iszero_320', 'gte_320']],
  ['mod_512', ['iszero_512', 'gte_512']],
  ['MOD', ['iszero_256', 'gte_256']],
  ['ADDMOD', ['MOD', 'ADD', 'mod_320']],
  ['MULMOD', ['mod_512']],
  ['SDIV', ['iszero_256', 'gte_256']],
  ['SMOD', ['iszero_256', 'gte_256']],
  ['DIV', ['iszero_256', 'gte_256']],
  ['EXP', ['iszero_256', 'mul_256']],
  ['MUL', ['mul_256']],
  ['ISZERO', ['iszero_256']],
  ['MSTORE', ['memusegas', 'bswap_m256', 'check_overflow']],
  ['MLOAD', ['memusegas', 'bswap_m256', 'check_overflow']],
  ['MSTORE8', ['memusegas', 'check_overflow']],
  ['CODECOPY', ['callback', 'memusegas', 'check_overflow', 'memset']],
  ['CALLDATALOAD', ['bswap_m256', 'bswap_i64', 'check_overflow']],
  ['CALLDATACOPY', ['memusegas', 'check_overflow', 'memset']],
  ['CALLVALUE', ['bswap_m128']],
  ['EXTCODECOPY', ['bswap_m256', 'callback', 'memusegas', 'check_overflow', 'memset']],
  ['EXTCODESIZE', ['callback_32', 'bswap_m256']],
  ['LOG', ['memusegas', 'check_overflow']],
  ['BLOCKHASH', ['check_overflow', 'callback_256']],
  ['SHA3', ['memusegas', 'bswap_m256', 'check_overflow', 'keccak']],
  ['CALL', ['memusegas', 'check_overflow_i64', 'check_overflow', 'memset', 'callback']],
  ['DELEGATECALL', ['callback', 'memusegas', 'check_overflow', 'memset']],
  ['CALLCODE', ['bswap_m256', 'callback', 'memusegas', 'check_overflow', 'memset']],
  ['CREATE', ['callback', 'memusegas', 'check_overflow']],
  ['RETURN', ['memusegas', 'check_overflow']],
  ['BALANCE', ['bswap_m256', 'callback_128']],
  ['SUICIDE', ['bswap_m256']],
  ['SSTORE', ['bswap_m256', 'callback']],
  ['SLOAD', ['callback_256']],
  ['CODESIZE', ['callback_32']],
  ['DIFFICULTY', ['bswap_m256']],
  ['COINBASE', ['bswap_m160']],
  ['ORIGIN', ['bswap_m160']],
  ['ADDRESS', ['bswap_m160']],
  ['CALLER', ['bswap_m160']]
])

/**
 * compiles evmCode to wasm in the binary format
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
  return exports.wast2wasm(exports.evm2wast(evmCode, opts))
}

/**
 * compiles wasm text format to binary
 * @param {string} wast
 * @return {buffer}
 */
exports.wast2wasm = function (wast) {
  fs.writeFileSync(`${__dirname}/temp.wast`, wast)
  cp.execSync(`${__dirname}/tools/sexpr-wasm-prototype/out/sexpr-wasm ${__dirname}/temp.wast -o ${__dirname}/temp.wasm`)
  return fs.readFileSync(`${__dirname}/temp.wasm`)
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
 * @param {Integer} evmCode the evm byte code
 * @param {Object} opts
 * @param {boolean} opts.stackTrace if `true` generates a stack trace
 * @param {boolean} opts.pprint if `true` pretty prints the sexpressions
 * @param {boolean} opts.inlineOps if `true` inlines the EVM1 operations
 * @return {string}
 */
exports.evm2wast = function (evmCode, opts = {
  'stackTrace': false,
  'pprint': false,
  'inlineOps': true
}) {
  // this keep track of the opcode we have found so far. This will be used to
  // to figure out what .wast files to include
  const opcodesUsed = new Set()
  const ignoredOps = new Set(['JUMP', 'JUMPI', 'JUMPDEST', 'POP', 'STOP', 'INVALID'])
  const callBackOps = new Map([
    ['SSTORE', 0],
    ['SLOAD', 2],
    ['CREATE', 0],
    ['CALL', 0],
    ['DELEGATECALL', 0],
    ['CALLCODE', 0],
    ['EXTCODECOPY', 0],
    ['EXTCODESIZE', 1],
    ['CODECOPY', 0],
    ['CODESIZE', 1],
    ['BALANCE', 3],
    ['BLOCKHASH', 2]
  ])

  // an array of found segments
  const jumpSegments = []
  // the transcompiled EVM code
  let wasmCode = ''
  let segment = ''
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
        segment += `;; jump
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
        segment += `(set_local $jump_dest (call $check_overflow 
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
        endSegment()
        jumpSegments.push({number: i, type: 'jump_dest'})
        gasCount = 1
        break
      case 'GAS':
        segment += `(call $${op.name} (get_local $sp))`
        addMetering()
        break
      case 'LOG':
        segment += `(call $${op.name} (i32.const ${op.number}) (get_local $sp))`
        break
      case 'DUP':
      case 'SWAP':
        // adds the number on the stack to SWAP
        segment += `(call $${op.name} (i32.const ${op.number - 1}) (get_local $sp)) `
        break
      case 'PC':
        segment += `(call $${op.name} (i32.const ${i}) (get_local $sp))`
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

        segment += `(call $${op.name} ${push} (get_local $sp))`
        i--
        break
      case 'POP':
        // do nothing
        break
      case 'STOP':
        segment += '(br $done)'
        if (jumpFound) {
          i = findNextJumpDest(evmCode, i)
        } else {
          // the rest is dead code
          i = evmCode.length
        }
        break
      case 'SUICIDE':
      case 'RETURN':
        segment += `(call $${op.name} (get_local $sp)) (br $done)`
        if (jumpFound) {
          i = findNextJumpDest(evmCode, i)
        } else {
          // the rest is dead code
          i = evmCode.length
        }
        break
      case 'INVALID':
        segment = '(unreachable)'
        i = findNextJumpDest(evmCode, i)
        break
      default:
        if (callBackOps.has(op.name)) {
          segment += `(call $${op.name} (get_local $sp) (i32.const ${callBackOps.get(op.name)}))`
        } else {
          segment += `(call $${op.name} (get_local $sp))`
        }
    }

    if (!ignoredOps.has(op.name)) {
      opcodesUsed.add(op.name)
    }

    const stackDeta = op.on - op.off
    // update the stack pointer
    if (stackDeta !== 0) {
      segment += `(set_local $sp (i32.add (get_local $sp) (i32.const ${stackDeta * 32})))`
    }

    // adds the logic to save the stack pointer before exiting to wiat to for a callback
    // note, this must be done before the sp is updated above^
    if (callBackOps.has(op.name)) {
      segment += `(i32.store (get_local $cb_dest_loc) (i32.const ${jumpSegments.length + 1}))
          (i32.store (get_local $sp_loc) (get_local $sp))
          (br $done))
          `
      jumpSegments.push({type: 'cb_dest'})
    }

    // creates a stack trace
    if (opts.stackTrace) {
      segment += `(call_import $stackTrace (get_local $sp) (i32.const ${opint}))`
    }
  }

  endSegment()

  wasmCode = assmebleSegments(jumpSegments) + wasmCode + ')'

  // import stack trace function
  if (opts.stackTrace) {
    wasmCode = '(import $printMem "debug" "printMemHex" (param i32 i32)) (import $print "debug" "print" (param i32)) (import $stackTrace "debug" "evmStackTrace" (param i32 i32)) ' + wasmCode
  }

  let funcMap = []
  // inline EVM opcode implemention
  if (opts.inlineOps) {
    funcMap = exports.resolveFunctions(opcodesUsed)
  }

  funcMap.push(wasmCode)
  wasmCode = exports.buildModule(funcMap)
  // pretty print the s-exporesion
  if (opts.pprint) {
    wasmCode = pprint(wasmCode)
  }
  return wasmCode

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
    segment = check + segment
    segmentStackHigh = 0
    segmentStackLow = 0
    segmentStackDeta = 0
  }

  // add a metering statment at the beginning of a segment
  function addMetering () {
    wasmCode += `(call_import $useGas (i64.const ${gasCount})) ` + segment
    segment = ''
    gasCount = 0
  }

  // finishes off a segment
  function endSegment () {
    segment += ')'
    addStackCheck()
    addMetering()
  }
}

// given an array for segments builds a wasm module from those segments
// @param {Array} segments
// @return {String}
function assmebleSegments (segments) {
  let wasm = buildJumpMap(segments)

  segments.forEach((seg, index) => {
    wasm = `(block $${index + 1} ${wasm}`
  })

  return `
    (export "main" $main)
    (func $main
         (param $isCallback i32)
         (local $cb_dest i32)
         (local $cb_dest_loc i32)
         (local $jump_dest i32)
         (local $sp i32)
         (local $sp_loc i32)

         (set_local $cb_dest_loc (i32.const 32780))
         (set_local $sp_loc (i32.const 32788))

         (if (i32.eqz (get_local $isCallback))
           (then 
             (set_local $sp (i32.const -32))
             (set_local $jump_dest (i32.const -1)))
           (else 
             ;; set up the stack pointer
             (set_local $sp (i32.load (get_local $sp_loc)))
             ;; set up call back destion
             (set_local $cb_dest (i32.load (get_local $cb_dest_loc)))
             ;; sets jump dest to a invalid location
             (set_local $jump_dest (i32.const -2))
           )
         )

         (loop $done $loop
          ${wasm}`
}

// Builds the Jump map, which maps EVM jump location to a block label
// @param {Array} segments
// @return {String}
function buildJumpMap (segments) {
  let wasm = `
    (if (i32.eq (get_local $jump_dest) (i32.const -1))
      (then (i32.const 0))
      (else
        ;; the callback dest can never be in the first block
        (if (i32.eq (get_local $cb_dest) (i32.const 0)) 
          (then (unreachable))
          (else 
            ;; use sp_loc as temp
            (set_local $isCallback (get_local $cb_dest))
            (set_local $cb_dest (i32.const 0))
            (get_local $isCallback)))))`

  let brTable = '(block $0 (br_table $0'
  segments.forEach((seg, index) => {
    brTable += ' $' + (index + 1)
    if (seg.type === 'jump_dest') {
      wasm = `(if (i32.eq (get_local $jump_dest) (i32.const ${seg.number}))
                    (then (i32.const ${index + 1}))
                    (else ${wasm}))`
    }
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
 // @param {Set} funcSet a set of wasm function that need to be linked to their dependencies
 // @return {Set}
function resolveFunctionDeps (funcSet) {
  let funcs = funcSet
  for (let func of funcSet) {
    const deps = depMap.get(func)
    if (deps) {
      for (const dep of deps) {
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
  for (let func of resolveFunctionDeps(funcSet)) {
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
          (import $useGas "ethereum" "useGas" (param i64))
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
