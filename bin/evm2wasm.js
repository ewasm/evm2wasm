#!/usr/bin/env node

const evm2wasm = require('../index.js')
const ethUtil = require('ethereumjs-util')
const argv = require('minimist')(process.argv.slice(2))
const fs = require('fs')

//read EVM bytecode from a file
function readEVM (file) {
  return new Promise((resolve, reject) => {
    if (file) {
      fs.readFile(file, (err, data) => {
        if (err) {
          reject(err)
        }

        resolve(data) // strip newline
      })
    } else {
      reject("no file")
    }
  })
}

//convert evm bytecode to WASM or WAST
function convert (bytecode, wast) {
  return new Promise((resolve, reject) => {
    outputFile = argv.o ? argv.o : undefined

    if(!bytecode) {
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

function storeOrPrintResult(output, outputFile) {
  return new Promise((resolve, reject) => {
    if (typeof(output) !== 'string') {
      output = output.buffer
    }
    if (outputFile) {
      fs.writeFile(outputFile, output, (err) => {
        if (err) {
          reject(err)
        }
      })
    } else {
      console.log(output)
      resolve()
    }
  })
}

(async () => {
  let outputFile = argv.o ? argv.o : undefined
  let wast = argv.wast !== undefined
  let file = argv.e ? argv.e : undefined

  let bytecode

  try {
    if (!file) {
      if (argv._.length > 0) {
        bytecode = argv._[0]  
      } else {
        throw("must provide evm bytecode file or supply bytecode as a non-named argument")
      }
    } else {
      bytecode = await readEVM(file)
    }

    debugger
    let result = await convert(bytecode, wast)
    await storeOrPrintResult(result, outputFile)
  } catch (err) {
    console.error("Error: " + err)
  }
}) ()
