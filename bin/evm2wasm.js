#!/usr/bin/env node

const evm2wasm = require('../index.js')
const ethUtil = require('ethereumjs-util')

const input = ethUtil.toBuffer(process.argv[2])

evm2wasm.evm2wasm(input, {
  stackTrace: process.argv[3] === 'trace',
  tempName: 'temp',
  inlineOps: true,
  wabt: true
}).then(function (output) {
  console.log(output.toString('binary'))
}).catch(function (err) {
  console.error('Failed: ' + err)
})
