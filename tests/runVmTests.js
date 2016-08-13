const argv = require('minimist')(process.argv.slice(2))
const tape = require('tape')
const ethUtil = require('ethereumjs-util')
const testing = require('ethereumjs-testing')
const Kernel = require('ewasm-kernel')
const Environment = require('ewasm-kernel/environment.js')
const Interface = require('ewasm-kernel/interface')
const evm2wasm = require('../index.js')

function runner (testData, t, cb) {
  const code = Buffer.from(testData.exec.code.slice(2), 'hex')
  const evm = evm2wasm.compile(code, argv.trace)
  const enviroment = setupEnviroment(testData)
  const ethInterface = new Interface(enviroment)

  try {
    const instance = Kernel.codeHandler(evm, ethInterface)
    checkResults(testData, t, instance, enviroment)
  } catch (e) {
    t.comment(e)
    t.equals(undefined, testData.post)
  }
  cb()
}

function setupEnviroment (testData) {
  const env = new Environment()
  env.gasLimit = parseInt(testData.exec.gas.slice(2), 16)
  env.callData = Buffer.from(testData.exec.data.slice(2), 'hex')
  return env
}

function checkResults (testData, t, instance, environment) {
  // check gas used
  t.equals(ethUtil.intToHex(environment.gasLimit), testData.gas, 'should have the correct gas')
  // check storage
  const testsStorage = testData.post[testData.exec.address].storage
  if (testsStorage) {
    for (let testKey in testsStorage) {
      const testValue = testsStorage[testKey]
      const key = new Buffer(testKey.slice(2), 'hex').reverse().toString('hex')
      let value = environment.state.get(key)
      if (value) {
        value = '0x' + new Buffer(value.reverse()).toString('hex')
      }

      t.equals(value, testValue, `should have correct storage value at key ${key}`)
    }
  }
}

const tests = testing.getTests('vm', argv)
const skip = []
testing.runTests(runner, tests, tape, skip)
