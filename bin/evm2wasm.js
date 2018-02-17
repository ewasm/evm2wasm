#!/usr/bin/env node

const evm2wasm = require('../index.js')
const argv = require('minimist')(process.argv.slice(2))
const fs = require('fs')

// convert evm bytecode to WASM or WAST
function convert (bytecode, wast) {
  return new Promise((resolve, reject) => {
    outputFile = argv.o ? argv.o : undefined

    if (!bytecode) {
      resolve(Buffer.from(''))
    }

    if (wast) {
      let output = evm2wasm.evm2wast(bytecode, {
        stackTrace: false,
        tempName: 'temp',
        inlineOps: true,
        wabt: false
      })
      resolve(output)
    } else {
      evm2wasm.evm2wasm(bytecode, {
        stackTrace: false,
        tempName: 'temp',
        inlineOps: true,
        wabt: false
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

let outputFile = argv.o ? argv.o : undefined
let wast = argv.wast !== undefined
let file = argv.e ? argv.e : undefined

let bytecode

try {
  if (!file) {
    if (argv._.length > 0) {
      bytecode = argv._[0]
    } else {
      throw new Error('must provide evm bytecode file or supply bytecode as a non-named argument')
    }
  } else {
    bytecode = fs.readFileSync(file)
  }

  convert(bytecode, wast).then((result) => {
    storeOrPrintResult(result, outputFile)
  }).catch((err) => {
    throw err
  })
} catch (err) {
  console.error('Error: ' + err)
}
