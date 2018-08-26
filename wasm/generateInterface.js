const fs = require('fs')
const path = require('path')
const assert = require('assert')

const wasmTypes = {
  // identity
  i32: 'i32',
  i64: 'i64',
  // custom data types
  readOffset: 'i32',
  writeOffset: 'i32',
  length: 'i32',
  ipointer: 'i32',
  opointer: 'i32',
  gasLimit: 'i64',
  // FIXME: these are handled wrongly currently
  address: 'i32',
  i128: 'i32',
  i256: 'i32'
}

const interfaceManifest = {
  LOG: {
    name: 'log',
    input: ['readOffset', 'length', 'i32', 'ipointer', 'ipointer', 'ipointer', 'ipointer'],
    output: []
  },
  CALLDATALOAD: {
    name: 'callDataCopy',
    input: ['writeOffset', 'i32', 'length'],
    output: []
  },
  GAS: {
    name: 'getGasLeft',
    input: [],
    output: ['i64']
  },
  ADDRESS: {
    name: 'getAddress',
    input: [],
    output: ['address']
  },
  BALANCE: {
    name: 'getBalance',
    async: true,
    input: ['address'],
    output: ['i128']
  },
  ORIGIN: {
    name: 'getTxOrigin',
    input: [],
    output: ['address']
  },
  CALLER: {
    name: 'getCaller',
    input: [],
    output: ['address']
  },
  CALLVALUE: {
    name: 'getCallValue',
    input: [],
    output: ['i128']
  },
  CALLDATASIZE: {
    name: 'getCallDataSize',
    input: [],
    output: ['i32']
  },
  CALLDATACOPY: {
    name: 'callDataCopy',
    input: ['writeOffset', 'i32', 'length'],
    output: []
  },
  CODESIZE: {
    name: 'getCodeSize',
    async: true,
    input: [],
    output: ['i32']
  },
  CODECOPY: {
    name: 'codeCopy',
    async: true,
    input: ['writeOffset', 'i32', 'length'],
    output: []
  },
  EXTCODESIZE: {
    name: 'getExternalCodeSize',
    async: true,
    input: ['address'],
    output: ['i32']
  },
  EXTCODECOPY: {
    name: 'externalCodeCopy',
    async: true,
    input: ['address', 'writeOffset', 'i32', 'length'],
    output: []
  },
  GASPRICE: {
    name: 'getTxGasPrice',
    input: [],
    output: ['i128'] // FIXME: shouldn't do it this way...
  },
  BLOCKHASH: {
    name: 'getBlockHash',
    async: true,
    input: ['i32'],
    output: ['i256']
  },
  COINBASE: {
    name: 'getBlockCoinbase',
    input: [],
    output: ['address']
  },
  TIMESTAMP: {
    name: 'getBlockTimestamp',
    input: [],
    output: ['i64']
  },
  NUMBER: {
    name: 'getBlockNumber',
    input: [],
    output: ['i64']
  },
  DIFFICULTY: {
    name: 'getBlockDifficulty',
    input: ['opointer'],
    output: []
  },
  GASLIMIT: {
    name: 'getBlockGasLimit',
    input: [],
    output: ['i64']
  },
  CREATE: {
    name: 'create',
    async: true,
    input: ['i128', 'readOffset', 'length'],
    output: ['address']
  },
  CALL: {
    name: 'call',
    async: true,
    input: ['gasLimit', 'address', 'i128', 'readOffset', 'length'],
    output: ['i32']
  },
  CALLCODE: {
    name: 'callCode',
    async: true,
    input: ['gasLimit', 'address', 'i128', 'readOffset', 'length'],
    output: ['i32']
  },
  DELEGATECALL: {
    name: 'callDelegate',
    async: true,
    input: ['gasLimit', 'address', 'i128', 'readOffset', 'length'],
    output: ['i32']
  },
  STATICCALL: {
    name: 'callStatic',
    async: true,
    input: ['gasLimit', 'address', 'readOffset', 'length'],
    output: ['i32']
  },
  RETURNDATACOPY: {
    name: 'returnDataCopy',
    input: ['writeOffset', 'i32', 'length'],
    output: []
  },
  RETURNDATASIZE: {
    name: 'getReturnDataSize',
    input: [],
    output: ['i32']
  },
  SSTORE: {
    name: 'storageStore',
    async: true,
    input: ['ipointer', 'ipointer'],
    output: []
  },
  SLOAD: {
    name: 'storageLoad',
    async: true,
    input: ['ipointer'],
    output: ['i256'] // TODO: this is wrong
  },
  SELFDESTRUCT: {
    name: 'selfDestruct',
    input: ['address'],
    output: []
  },
  RETURN: {
    name: 'finish',
    input: ['readOffset', 'length'],
    output: []
  },
  REVERT: {
    name: 'revert',
    input: ['readOffset', 'length'],
    output: []
  }
}

function toWasmType (type) {
  const ret = wasmTypes[type]
  assert(ret === 'i32' || ret === 'i64')
  return ret
}

function getStackItem (spOffset, shiftOffset) {
  shiftOffset = shiftOffset || 0
  if (spOffset === 0 && shiftOffset === 0) {
    return '(get_global $sp)'
  } else {
    return `(i32.add (get_global $sp) (i32.const ${spOffset * 32 + shiftOffset}))`
  }
}

function checkOverflowStackItem64 (spOffset) {
  return `(call $check_overflow_i64
          (i64.load ${getStackItem(spOffset, 8 * 0)})
          (i64.load ${getStackItem(spOffset, 8 * 1)})
          (i64.load ${getStackItem(spOffset, 8 * 2)})
          (i64.load ${getStackItem(spOffset, 8 * 3)}))`
}

function checkOverflowStackItem256 (spOffset) {
  return `(call $check_overflow
          (i64.load ${getStackItem(spOffset, 8 * 0)})
          (i64.load ${getStackItem(spOffset, 8 * 1)})
          (i64.load ${getStackItem(spOffset, 8 * 2)})
          (i64.load ${getStackItem(spOffset, 8 * 3)}))`
}

// assumes the stack contains 160 bits of value and clears the rest
function cleanupStackItem160 (spOffset) {
  return `
    ;; zero out mem
    (i64.store ${getStackItem(spOffset, 8 * 3)} (i64.const 0))
    (i32.store ${getStackItem(spOffset, 8 * 2 + 4)} (i32.const 0))`
}

// assumes the stack contains 128 bits of value and clears the rest
function cleanupStackItem128 (spOffset) {
  return `
    ;; zero out mem
    (i64.store ${getStackItem(spOffset, 8 * 3)} (i64.const 0))
    (i64.store ${getStackItem(spOffset, 8 * 2)} (i64.const 0))`
}

// assumes the stack contains 64 bits of value and clears the rest
function cleanupStackItem64 (spOffset) {
  return `
    ;; zero out mem
    (i64.store ${getStackItem(spOffset, 8 * 3)} (i64.const 0))
    (i64.store ${getStackItem(spOffset, 8 * 2)} (i64.const 0))
    (i64.store ${getStackItem(spOffset, 8 * 1)} (i64.const 0))`
}

function generateManifest (interfaceManifest, opts) {
  const useAsyncAPI = opts.useAsyncAPI
  const json = {}
  for (let opcode in interfaceManifest) {
    const op = interfaceManifest[opcode]
    // Translate input types to native wasm types
    let inputs = op.input.map(type => toWasmType(type))
    // Also add output types which are non-basic because they need to be passed as inputs
    inputs = inputs.concat(op.output.filter(type => type !== 'i32' && type !== 'i64').map(type => toWasmType(type)))
    let params = ''

    if (useAsyncAPI && op.async) {
      inputs.push('i32')
    }

    if (inputs.length) {
      params = `(param ${inputs.join(' ')})`
    }

    let result = ''
    const firstResult = op.output[0]
    if (firstResult === 'i32' || firstResult === 'i64') {
      result = `(result ${firstResult})`
    }
    // generate import
    const imports = `(import "ethereum" "${op.name}" (func $${op.name} ${params} ${result}))`
    let wasm = ';; generated by ./wasm/generateInterface.js\n'
      // generate function
    wasm += `(func $${opcode} `
    if (useAsyncAPI && op.async) {
      wasm += '(param $callback i32)'
    }

    let locals = ''
    let body = ''

    // generate the call to the interface
    let spOffset = 0
    let numOfLocals = 0
    let lastOffset
    let call = `(call $${op.name}`
    op.input.forEach((input) => {
      if (input === 'i128' || input === 'address') {
        if (input === 'address') {
          call += `(call $bswap_m160 ${getStackItem(spOffset)})`
        } else {
          call += getStackItem(spOffset)
        }
      } else if (input === 'ipointer') {
        // input pointer
        // points to a wasm memory offset where input data will be read
        // the wasm memory offset is an existing item on the EVM stack
        if (opcode === 'SLOAD' || opcode === 'SSTORE') {
          call += `(call $bswap_m256 ${getStackItem(spOffset)})`
        } else {
          call += getStackItem(spOffset)
        }
      } else if (input === 'opointer') {
        // output pointer
        // points to a wasm memory offset where the result should be written
        // the wasm memory offset is a new item on the EVM stack
        spOffset++
        call += getStackItem(spOffset)
      } else if (input === 'gasLimit') {
        // i64 param for CALL is the gas
        // add 2300 gas subsidy
        // for now this only works if the gas is a 64-bit value
        // TODO: use 256-bit arithmetic
        /*
        call += `(call $check_overflow_i64
           (i64.add (i64.const 2300)
             (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32}))))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3}))))`
        */

        // 2300 gas subsidy is done in Hera
        call += checkOverflowStackItem64(spOffset)
      } else if (input === 'i32') {
        call += checkOverflowStackItem256(spOffset)
      } else if (input === 'i64') {
        call += checkOverflowStackItem64(spOffset)
      } else if (input === 'writeOffset' || input === 'readOffset') {
        lastOffset = input
        locals += `(local $offset${numOfLocals} i32)`
        body += `(set_local $offset${numOfLocals} ${checkOverflowStackItem256(spOffset)})`
        call += `(get_local $offset${numOfLocals})`
      } else if (input === 'length' && (opcode === 'CALL' || opcode === 'CALLCODE' || opcode === 'DELEGATECALL' || opcode === 'STATICCALL')) {
        // CALLs in EVM have 7 arguments
        // but in ewasm CALLs only have 5 arguments
        // so delete the bottom two stack elements, after processing the 5th argument

        locals += `(local $length${numOfLocals} i32)`
        body += `(set_local $length${numOfLocals} ${checkOverflowStackItem256(spOffset)})`

        body += `
    (call $memusegas (get_local $offset${numOfLocals}) (get_local $length${numOfLocals}))
    (set_local $offset${numOfLocals} (i32.add (get_global $memstart) (get_local $offset${numOfLocals})))`

        call += `(get_local $length${numOfLocals})`
        numOfLocals++

        // delete 6th stack element
        spOffset--

        // delete 7th stack element
        spOffset--
      } else if (input === 'length' && (opcode !== 'CALL' && opcode !== 'CALLCODE' && opcode !== 'DELEGATECALL' && opcode !== 'STATICCALL')) {
        locals += `(local $length${numOfLocals} i32)`
        body += `(set_local $length${numOfLocals} ${checkOverflowStackItem256(spOffset)})`

        body += `
    (call $memusegas (get_local $offset${numOfLocals}) (get_local $length${numOfLocals}))
    (set_local $offset${numOfLocals} (i32.add (get_global $memstart) (get_local $offset${numOfLocals})))`

        call += `(get_local $length${numOfLocals})`
        numOfLocals++
      }
      spOffset--
    })

    spOffset++

    // generate output handling
    const output = op.output.shift()
    if (output === 'i128') {
      call += getStackItem(spOffset)

      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call += ')'
      call += cleanupStackItem128(spOffset)
    } else if (output === 'address') {
      call += getStackItem(spOffset)

      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call += ')'
      // change the item from BE to LE
      call += `(drop (call $bswap_m160 ${getStackItem(spOffset)}))`
      call += cleanupStackItem160(spOffset)
    } else if (output === 'i256') {
      call += getStackItem(spOffset)

      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call += ')'
      // change endianess from BE to LE
      call += `(drop (call $bswap_m256 ${getStackItem(spOffset)}))`
    } else if (output === 'i32') {
      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      if (opcode === 'CALL' || opcode === 'CALLCODE' || opcode === 'DELEGATECALL' || opcode === 'STATICCALL') {
        // flip CALL result from EEI to EVM convention (0 -> 1, 1,2,.. -> 1)
        call = `(i64.store ${getStackItem(spOffset)} (i64.extend_u/i32 (i32.eqz ${call})))`
      } else {
        call = `(i64.store ${getStackItem(spOffset)} (i64.extend_u/i32 ${call}))`
      }

      call += ')'
      call += cleanupStackItem64(spOffset)
    } else if (output === 'i64') {
      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }
      call = `(i64.store ${getStackItem(spOffset)} ${call})`

      call += ')'
      call += cleanupStackItem64(spOffset)
    } else if (!output) {
      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }
      call += ')'
    }

    wasm += `${locals} ${body} ${call})`
    json[opcode] = {
      wast: wasm,
      imports: imports
    }
  }

  // add math ops
  const files = fs.readdirSync(__dirname).filter(file => file.slice(-5) === '.wast')
  files.forEach((file) => {
    const wast = fs.readFileSync(path.join(__dirname, file)).toString()
    file = file.slice(0, -5)
    // don't overwrite import generation
    json[file] = json[file] || {}
    json[file].wast = wast
  })

  return json
}

function generateCPPHeader(interfaceManifest, opts) {
  function quoteString(str) {
    // from https://stackoverflow.com/questions/770523/escaping-strings-in-javascript
    return JSON.stringify(str).slice(1, -1);
  }

  function escapeNewlines(str) {
    return str.replace(/\n/gi, '\n')
  }

  let entries = []

  for (let opcode in interfaceManifest) {
    const wast = quoteString(escapeNewlines(interfaceManifest[opcode].wast))
    const imports = quoteString(escapeNewlines(interfaceManifest[opcode].imports || ""))

    entries.push(`{
  opcodeEnum::${opcode}, {
    .wast = "${wast}",
    .imports = "${imports}"
  }
}`)
  }

  const interfaceName = opts.useAsyncAPI ? 'wastAsyncInterface' : 'wastSyncInterface'

  return `#pragma once

#include <map>

#include "evm2wasm.h"

namespace evm2wasm
{
  static std::map<opcodeEnum, WastCode> ${interfaceName} =
  {
    ${entries.join()}
  };
}`
}

// generateManifest mutates the input, so use a copy
const interfaceManifestCopy = JSON.parse(JSON.stringify(interfaceManifest))

let syncJson = generateManifest(interfaceManifest, {'useAsyncAPI': false})
let asyncInterfaceJson = generateManifest(interfaceManifestCopy, {'useAsyncAPI': true})

fs.writeFileSync(path.join(__dirname, 'wast.json'), JSON.stringify(syncJson, null, 2))
fs.writeFileSync(path.join(__dirname, 'wast-async.json'), JSON.stringify(asyncInterfaceJson, null, 2))

// generate C++ header
fs.writeFileSync(path.join(__dirname, '../include/wast.h'), generateCPPHeader(syncJson, {'useAsyncAPI': false}))
fs.writeFileSync(path.join(__dirname, '../include/wast-async.h'), generateCPPHeader(asyncInterfaceJson, {'useAsyncAPI': true}))
