const argv = require('minimist')(process.argv.slice(2))
const tape = require('tape')
const testing = require('ethereumjs-testing')
const Kernel = require('ewasm-kernel')
const evm2wasm = require('../index.js')

function runner (testData, t, cb) {
  const code = new Buffer(testData.exec.code.slice(2), 'hex')
  const evm = evm2wasm.compile(code)
  const instance = Kernel.codeHandler(evm)
  cb()
}

const tests = testing.getTests('vm', argv)
const skip = []
testing.runTests(runner, tests, tape, skip)

