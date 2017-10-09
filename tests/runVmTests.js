const argv = require('minimist')(process.argv.slice(2))
const tape = require('tape')
const ethUtil = require('ethereumjs-util')
const testing = require('ethereumjs-testing')
const Kernel = require('ewasm-kernel')
const Environment = require('ewasm-kernel/environment.js')
const Address = require('ewasm-kernel/deps/address.js')
const U256 = require('ewasm-kernel/deps/u256.js')
const evm2wasm = require('../index.js').evm2wasm
const Vertex = require('merkle-trie')

const Interface = require('ewasm-kernel/EVMimports')
const DebugInterface = require('ewasm-kernel/debugInterface')

// tests that we are skipping
// const skipList = [
//   'sha3_bigOffset2' // some wierd memory error when we try to allocate 16mb of mem
// ]

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
  } = await evm2wasm(code, {
    stackTrace: argv.trace,
    testName: testName,
    inlineOps: true,
    pprint: false,
    wabt: true
  })
  
  const rootVertex = new Vertex()
  const enviroment = setupEnviroment(testData, rootVertex)
  try {
    const kernel = new Kernel({
      code: evm,
      interfaces: [Interface, DebugInterface]
    })
    const instance = await kernel.run(enviroment)
    await checkResults(testData, t, instance, enviroment)
  } catch (e) {
    t.fail('VM test runner caught exception: ' + e)
  }
  return
}

function setupEnviroment (testData, rootVertex) {
  const env = new Environment()

  env.gasLeft = parseInt(testData.exec.gas.slice(2), 16)
  env.callData = new Uint8Array(Buffer.from(testData.exec.data.slice(2), 'hex'))
  env.gasPrice = ethUtil.bufferToInt(Buffer.from(testData.exec.gasPrice.slice(2), 'hex'))

  env.address = new Address(testData.exec.address)
  env.caller = new Address(testData.exec.caller)
  env.origin = new Address(testData.exec.origin)
  env.value = new U256(testData.exec.value)

  env.callValue = new U256(testData.exec.value)
  env.code = new Uint8Array(new Buffer(testData.exec.code.slice(2), 'hex'))

  // setup block
  env.block.header.number = testData.env.currentNumber
  env.block.header.coinbase = new Buffer(testData.env.currentCoinbase.slice(2), 'hex')
  env.block.header.difficulty = testData.env.currentDifficulty
  env.block.header.gasLimit = new Buffer(testData.env.currentGasLimit.slice(2), 'hex')
  env.block.header.number = new Buffer(testData.env.currentNumber.slice(2), 'hex')
  env.block.header.timestamp = new Buffer(testData.env.currentTimestamp.slice(2), 'hex')

  for (let address in testData.pre) {
    const account = testData.pre[address]
    const accountVertex = new Vertex()

    accountVertex.set('code', new Vertex({
      value: new Buffer(account.code.slice(2), 'hex')
    }))

    accountVertex.set('balance', new Vertex({
      value: new Buffer(account.balance.slice(2), 'hex')
    }))

    for (let key in account.storage) {
      accountVertex.set(['storage', ...new Buffer(key.slice(2), 'hex')], new Vertex({
        value: new Buffer(account.storage[key].slice(2), 'hex')
      }))
    }

    const path = [...new Buffer(address.slice(2), 'hex')]
    rootVertex.set(path, accountVertex)
    env.state = accountVertex
  }

  return env
}

async function fail (t, e) {
  t.ok(false, 'VM test runner caught exception:' + e)
}

async function checkResults (testData, t, instance, environment) {
  // check gas used
  t.equals(ethUtil.intToHex(environment.gasLeft), testData.gas, 'should have the correct gas')
  // check return value
  t.equals(new Buffer(environment.returnValue).toString('hex'), testData.out.slice(2), 'return value')
  // check storage
  const account = testData.post[testData.exec.address]
  // TODO: check all accounts
  if (account) {
    const testsStorage = account.storage
    if (testsStorage) {
      for (let testKey in testsStorage) {
        const testValueBuf = ethUtil.setLengthLeft(ethUtil.toBuffer(testsStorage[testKey]), 32)
        const testValue = '0x' + testValueBuf.toString('hex')
        const bufferKey = ethUtil.setLengthLeft(ethUtil.toBuffer(testKey), 32)
        const key = ['storage', ...bufferKey]
        let {value} = await environment.state.get(key)
        if (value) {
          value = '0x' + new Buffer(value).toString('hex')
        }
        t.equals(value, testValue, `should have correct storage value at key ${key.join('')}`)
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
