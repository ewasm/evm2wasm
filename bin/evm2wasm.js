#!/usr/bin/env node

const evm2wasm = require('../index.js')
const argv = require('minimist')(process.argv.slice(2))
const fs = require('fs')

console.log('evm2wasm.js process.argv:', process.argv)

// convert evm bytecode to WASM or WAST
function convert (bytecode, opts) {
  return new Promise((resolve, reject) => {
    if (!bytecode) {
      return resolve(Buffer.from(''))
    }

    if (opts.wast) {
      let output = evm2wasm.evm2wast(bytecode, {
        stackTrace: opts.trace,
        tempName: 'temp',
        inlineOps: true,
        wabt: false,
        chargePerOp: opts.chargePerOp
      })
      resolve(output)
    } else {
      evm2wasm.evm2wasm(bytecode, {
        stackTrace: opts.trace,
        tempName: 'temp',
        inlineOps: true,
        wabt: false,
        chargePerOp: opts.chargePerOp
      }).then(function (output) {
        resolve(output)
      }).catch(function (err) {
        reject(err)
      })
    }
  })
}

function storeOrPrintResult (output, outputFile) {
  if (typeof output !== 'string') {
    output = output.buffer
  }

  if (outputFile) {
    fs.writeFileSync(outputFile, output)
  } else {
    console.log(Buffer.from(output).toString('binary'))
  }
}

console.log('evm2wasm.js argv:', argv)

const outputFile = argv.o ? argv.o : undefined
const wast = argv.wast !== undefined
const trace = argv.trace !== undefined
const inputFile = argv.e ? argv.e : undefined
const chargePerOp = argv['charge-per-op'] ? argv['charge-per-op'] : undefined

let bytecode

try {
  console.log('evm2wasm.js inputFile:', inputFile)
  if (!inputFile) {
    if (argv._.length > 0) {
      // ensure it is a string even it was passed as a number
      bytecode = argv._[0].toString()
    } else {
      throw new Error('must provide evm bytecode file or supply bytecode as a non-named argument')
    }
  } else {
    console.log('evm2wasm.js calling fs.readFileSync...')
    bytecode = fs.readFileSync(inputFile).toString()
  }

  console.log('evm2wasm.js converting bytecode to buffer..')
  // always consider input EVM as a hex string and translate that into binary for the next stage
  bytecode = Buffer.from(bytecode, 'hex')

  console.log('evm2wasm.js calling convert..')
  convert(bytecode, { wast: wast, trace: trace, chargePerOp: chargePerOp }).then((result) => {
    storeOrPrintResult(result, outputFile)
  }).catch((err) => {
    throw err
  })
} catch (err) {
  console.error('Error: ' + err)
  process.exit(1)
}
