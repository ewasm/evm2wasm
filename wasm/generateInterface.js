const fs = require('fs')
const path = require('path')

const EEI = {
  useGas: '(import "ethereum" "useGas" (func $useGas (param i32)))',
  getAddress: '(import "ethereum" "getAddress" (func $getAddress (param i32)))',
  getBalance: '(import "ethereum" "getBalance" (func $getBalance (param i32 i32)))',
  getBlockHash: '(import "ethereum" "getBlockHash" (func $getBlockHash (param i64 i32)))',
  call: '(import "ethereum" "call" (func $call (param i64 i32 i32 i32 i32 i32 i32) (result i32)))',
  callDataCopy: '(import "ethereum" "callDataCopy" (func $callDataCopy (param i32 i32 i32)))',
  getCallDataSize: '(import "ethereum" "getCallDataSize" (func $getCallDataSize (result i32)))',
  callCode: '(import "ethereum" "callCode" (func $callCode (param i64 i32 i32 i32 i32 i32 i32) (result i32)))',
  callDelegate: '(import "ethereum" "callDelegate" (func $callDelegate (param i64 i32 i32 i32) (result i32)))',
  callStatic: '(import "ethereum" "callStatic" (func $callStatic (param i64 i32 i32 i32) (result i32)))',
  storageStore: '(import "ethereum" "storageStore" (func $storageStore (param i32 i32)))',
  storageLoad: '(import  "ethereum" "storageLoad"  (func $storageLoad (param i32 i32)))',
  getCaller: '(import "ethereum" "getCaller" (func $getCaller (param i32)))',
  getCallValue: '(import "ethereum" "getCallValue" (func $getCallValue (param i32)))',
  codeCopy: '(import  "ethereum" "codeCopy"  (func $codeCopy (param i32 i32 i32)))',
  getCodeSize: '(import "ethereum" "getCodeSize" (func $getCodeSize (result i32)))',
  getBlockCoinbase: '(import "ethereum" "getBlockCoinbase" (func $getBlockCoinbase (param i32)))',
  create: '(import "ethereum" "create" (func $create (param i32 i32 i32 i32) (result i32)))',
  getBlockDifficulty: '(import "ethereum" "getBlockDifficulty" (func $getBlockDifficulty (param i32)))',
  externalCodeCopy: '(import  "ethereum" "externalCodeCopy"  (func $externalCodeCopy (param i32 i32 i32 i32)))',
  getExternalCodeSize: '(import "ethereum" "getExternalCodeSize" (func $getExternalCodeSize (param i32) (result i32)))',
  getGasLeft: '(import "ethereum" "getGasLeft" (func $getGasLeft (result i64)))',
  getBlockGasLimit: '(import  "ethereum" "getBlockGasLimit"  (func $getBlockGasLimit (result i64)))',
  getTxGasPrice: '(import  "ethereum" "getTxGasPrice"  (func $getTxGasPrice (param i32)))',
  log: '',
  getBlockNumber: '(import "ethereum" "getBlockNumber" (func $getBlockNumber (result i64)))',
  getTxOrigin: '(import  "ethereum" "getTxOrigin"  (func $getTxOrigin (param i32 )))',
  return: '(import "ethereum" "return" (func $return (param i32 i32)))',
  revert: '(import "ethereum" "revert" (func $return (param i32 i32)))',
  getReturnDataSize: '(import "ethereum" "getReturnDataSize" (func $getReturnDataSize (result i32)))',
  returnDataCopy: '(import "ethereum" "returnDataCopy" (func $returnDataCopy (param i32 i32 i32)))',
  selfDestruct: '(import "ethereum" "selfDestruct" (func $selfDestruct (param i32)))',
  getBlockTimestamp: '(import  "ethereum" "getBlockTimestamp"  (func $getBlockTimestamp (result i64)))'
}

const interfaceManifest = {
  LOG: {
    name: 'log',
    input: ['readOffset', 'length', 'i32', 'ipointer', 'ipointer', 'ipointer', 'ipointer'],
    output: []
  },
  CALLDATALOAD: {
    name: 'callDataCopy256',
    input: ['pointer'],
    output: ['i256'] // TODO: this is wrong
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
    input: ['opointer'],
    output: []
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
    input: ['i64', 'address', 'i128', 'readOffset', 'length', 'writeOffset', 'length'],
    output: ['i32']
  },
  CALLCODE: {
    name: 'callCode',
    async: true,
    input: ['i32', 'address', 'i128', 'readOffset', 'length', 'writeOffset', 'length'],
    output: ['i32']
  },
  DELEGATECALL: {
    name: 'callDelegate',
    async: true,
    input: ['i32', 'address', 'i128', 'readOffset', 'length', 'writeOffset', 'length'],
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
    name: 'return',
    input: ['readOffset', 'length'],
    output: []
  }
}

function generateManifest (interfaceManifest, opts) {
  const useAsyncAPI = opts.useAsyncAPI
  const json = {}
  for (let opcode in interfaceManifest) {
    const op = interfaceManifest[opcode]
      // generate the import params
    if (opcode == 'CALLCODE') {
      debugger
    }

    let inputs = op.input.map(input => input === 'i64' ? 'i64' : 'i32').concat(op.output.filter(type => type !== 'i32' && type !== 'i64').map(() => 'i32'))
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
      // TODO: remove 'pointer' type, replace with 'ipointer' or 'opointer'
      if (input === 'i128' || input == 'address' || input == 'pointer') {
        if (spOffset) {
          call += `(i32.add (get_global $sp) (i32.const ${spOffset * 32}))`
        } else {
          call += '(get_global $sp)'
        }
      } else if (input === 'ipointer') {
        // input pointer
        // points to a wasm memory offset where input data will be read
        // the wasm memory offset is an existing item on the EVM stack
        if (spOffset) {
          call += `(i32.add (get_global $sp) (i32.const ${spOffset * 32}))`
        } else {
          call += '(get_global $sp)'
        }
      } else if (input === 'opointer') {
        // output pointer
        // points to a wasm memory offset where the result should be written
        // the wasm memory offset is a new item on the EVM stack
        spOffset++
        call += `(i32.add (get_global $sp) (i32.const ${spOffset * 32}))`
      } else if (input === 'i32') {
        call += `(call $check_overflow
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3}))))`
      } else if (input === 'i64') {
        call += `(call $check_overflow_i64
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})))
           (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3}))))`
      } else if (input === 'writeOffset' || input === 'readOffset') {
        lastOffset = input
        locals += `(local $offset${numOfLocals} i32)`
        body += `(set_local $offset${numOfLocals} 
    (call $check_overflow
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32})))
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})))
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})))
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3})))))`
        call += `(get_local $offset${numOfLocals})`
      } else if (input === 'length') {
        locals += `(local $length${numOfLocals} i32)`
        body += `(set_local $length${numOfLocals} 
    (call $check_overflow 
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32})))
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})))
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})))
      (i64.load (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3})))))

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
      call =
        `${call} (i32.add (get_global $sp) (i32.const ${spOffset * 32}))`

      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call += `)
    ;; zero out mem
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3})) (i64.const 0))
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})) (i64.const 0))`

      if (!op.async) {
        call += '(drop (call $bswap_m128 (i32.add (i32.const 32)(get_global $sp))))'
      }
    } else if (output === 'address') {
      call =
        `${call} (i32.add (get_global $sp) (i32.const ${spOffset * 32}))`

      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call += `)
    (drop (call $bswap_m160 (i32.add (get_global $sp) (i32.const ${spOffset * 32}))))
    ;; zero out mem
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3})) (i64.const 0))
    (i32.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2 + 4})) (i32.const 0))`
    } else if (output === 'i256') {
      call = `${call} 
    (i32.add (get_global $sp) 
    (i32.const ${spOffset * 32}))`

      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call += `)
      (drop (call $bswap_m256 (i32.add (i32.const 32) (get_global $sp))))
      `
    } else if (output === 'i32') {
      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }

      call =
        `(i64.store
    (i32.add (get_global $sp) (i32.const ${spOffset * 32}))
    (i64.extend_u/i32
      ${call})))

    ;; zero out mem
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3})) (i64.const 0))
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})) (i64.const 0))
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})) (i64.const 0))`
    } else if (output === 'i64') {
      if (useAsyncAPI && op.async) {
        call += '(get_local $callback)'
      }
      call =
        `(i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32})) ${call}))

    ;; zero out mem
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 3})) (i64.const 0))
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8 * 2})) (i64.const 0))
    (i64.store (i32.add (get_global $sp) (i32.const ${spOffset * 32 + 8})) (i64.const 0))`
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
  return json
}

// generateManifest mutates the input, so use a copy
const interfaceManifestCopy = JSON.parse(JSON.stringify(interfaceManifest))

let syncJson = generateManifest(interfaceManifest, {'useAsyncAPI': false})
let asyncInterfaceJson = generateManifest(interfaceManifestCopy, {'useAsyncAPI': true})
// add math ops
const files = fs.readdirSync(__dirname).filter(file => file.slice(-5) === '.wast')
files.forEach((file) => {
  const wast = fs.readFileSync(path.join(__dirname, file)).toString()
  file = file.slice(0, -5)
  // don't overwrite import generation
  syncJson[file] = syncJson[file] || {}
  syncJson[file].wast = wast

  asyncInterfaceJson[file] = asyncInterfaceJson[file] || {}
  asyncInterfaceJson[file].wast = wast
})

fs.writeFileSync(path.join(__dirname, 'wast.json'), JSON.stringify(syncJson, null, 2))
fs.writeFileSync(path.join(__dirname, 'wast-async.json'), JSON.stringify(asyncInterfaceJson, null, 2))
