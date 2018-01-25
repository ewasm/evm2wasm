const argv = require('minimist')(process.argv.slice(2))
const tape = require('tape')
const ethUtil = require('ethereumjs-util')
const testing = require('ethereumjs-testing')
const Kernel = require('ewasm-kernel')
const Environment = require('ewasm-kernel/environment.js')
const Address = require('ewasm-kernel/deps/address.js')
const U256 = require('ewasm-kernel/deps/u256.js')
const evm2wasm = require('../index.js')

const Interface = require('ewasm-kernel/EVMimports')
const DebugInterface = require('ewasm-kernel/debugInterface')

const skipList = [
  // slow performance tests
  'loop-mul',
  'loop-add-10M',
  'loop-divadd-10M',
  'loop-divadd-unr100-10M',
  'loop-exp-16b-100k',
  'loop-exp-1b-1M',
  'loop-exp-2b-100k',
  'loop-exp-32b-100k',
  'loop-exp-4b-100k',
  'loop-exp-8b-100k',
  'loop-exp-nop-1M',
  'loop-mulmod-2M'
]

async function runner (testName, testData, t) {
  const code = Buffer.from(testData.exec.code.slice(2), 'hex')
  const {
    buffer: evm
  } = await evm2wasm.evm2wasm(code, {
    stackTrace: argv.trace,
    useAsyncAPI: true,
    testName: testName,
    inlineOps: true,
    wabt: true
  })

  const environment = setupEnviroment(testData)
  let instance
  let vmExceptionErr = null
  try {
    const kernel = new Kernel({
      code: evm,
      interfaces: [Interface, DebugInterface]
    })
    instance = await kernel.run(environment)
  } catch (e) {
    vmExceptionErr = e
  } finally {
    await checkResults(testData, t, instance, environment, vmExceptionErr)
  }
}

function setupEnviroment (testData) {
  const env = new Environment()

  env.gasLeft = parseInt(testData.exec.gas.slice(2), 16)
  env.callData = new Uint8Array(Buffer.from(testData.exec.data.slice(2), 'hex'))
  env.gasPrice = ethUtil.bufferToInt(Buffer.from(testData.exec.gasPrice.slice(2), 'hex'))

  env.address = new Address(testData.exec.address)
  env.caller = new Address(testData.exec.caller)
  env.origin = new Address(testData.exec.origin)
  env.value = new U256(testData.exec.value)

  env.callValue = new U256(testData.exec.value)
  env.code = new Uint8Array(Buffer.from(testData.exec.code.slice(2), 'hex'))

  // setup block
  env.block.header.number = testData.env.currentNumber
  env.block.header.coinbase = Buffer.from(testData.env.currentCoinbase.slice(2), 'hex')
  env.block.header.difficulty = testData.env.currentDifficulty
  env.block.header.gasLimit = Buffer.from(testData.env.currentGasLimit.slice(2), 'hex')
  env.block.header.number = Buffer.from(testData.env.currentNumber.slice(2), 'hex')
  env.block.header.timestamp = Buffer.from(testData.env.currentTimestamp.slice(2), 'hex')

  env.state = {}
  for (let address in testData.pre) {
    const testAccount = testData.pre[address]
    let envAccount = {
      code: testAccount.code,
      balance: testAccount.balance,
      storage: testAccount.storage
    }

    env.state[address] = envAccount
  }

  return env
}

async function checkResults (testData, t, instance, environment, vmExceptionErr) {
  // https://github.com/ethereum/tests/wiki/VM-Tests
  // > It is generally expected that the test implementer will read env, exec
  // and pre then check their results against gas, logs, out, post and
  // callcreates. If an exception is expected, then latter sections are absent
  // in the test.

  if ((testData.gas && testData.out && testData.post)) {
    if (vmExceptionErr) {
      t.fail('should not have VM exception')
      console.log('vmExceptionErr:', vmExceptionErr)
    }
  } else {
    // if any of the expected fields are missing then a VM exception is expected
    t.true(vmExceptionErr, 'should have VM exception')
  }

  if (testData.gas) {
    t.equals(ethUtil.intToHex(environment.gasLeft), testData.gas, 'should have the correct gas')
  }

  // check return value
  if (testData.out) {
    t.equals(Buffer.from(environment.returnValue).toString('hex'), testData.out.slice(2), 'return value')
  }

  // check storage
  if (testData.post) {
    const expectedAccount = testData.post[testData.exec.address]
    // TODO: check all accounts
    if (expectedAccount) {
      const expectedStorage = expectedAccount.storage
      if (expectedStorage) {
        for (let key in expectedStorage) {
          const keyHex = (new U256(key)).toString(16)
          // pad values to get consistent hex strings for comparison
          let expectedValue = ethUtil.setLengthLeft(ethUtil.toBuffer(expectedStorage[key]), 32)
          expectedValue = '0x' + expectedValue.toString('hex')
          let actualValue = environment.state[testData.exec.address]['storage'][keyHex]
          if (actualValue) {
            actualValue = '0x' + ethUtil.setLengthLeft(ethUtil.toBuffer(actualValue), 32).toString('hex')
          } else {
            actualValue = '0x' + ethUtil.setLengthLeft(ethUtil.toBuffer(0), 32).toString('hex')
          }
          t.equals(actualValue, expectedValue, `should have correct storage value at key ${key}`)
        }
      }
    }
  }
}

let testGetterArgs = {}
testGetterArgs.skipVM = skipList

tape('VMTESTS', t => {
  testing.getTestsFromArgs('VMTests', (fileName, testName, tests) => {
    t.comment(fileName + ' ' + testName)
    return runner(testName, tests, t).catch(err => {
      t.fail(err)
    })
  }, testGetterArgs).then(() => {
    t.end()
  })
})
