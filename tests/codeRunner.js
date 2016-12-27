const fs = require('fs')
const tape = require('tape')
const Vertex = require('merkle-trie')
const evm2wasm = require('../index.js')
const ethUtil = require('ethereumjs-util')
const Kernel = require('ewasm-kernel')
const Enviroment = require('ewasm-kernel/environment')
const Address = require('ewasm-kernel/deps/address')
const argv = require('minimist')(process.argv.slice(2))

const dir = `${__dirname}/code/`
let testFiles

if (argv.file) {
  // run a single file
  testFiles = [argv.file]
} else {
  testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))
}

tape('testing transcompiler', async t => {
  for (let path of testFiles) {
    t.comment(path)
    let codeTests = require(dir + path)
    for (let test of codeTests) {
      t.comment(test.description)

      const environment = new Enviroment()
      environment.gasLeft = 90000
      environment.block.header.coinbase = test.environment.coinbase
      environment.origin = new Address(test.environment.origin)
      if (test.environment.callData) {
        environment.callData = new Buffer(test.environment.callData.slice(2), 'hex')
      }
      const code = new Buffer(test.code.slice(2), 'hex')

      environment.state.set('code', new Vertex({value: code}))

      const startGas = environment.gasLeft

      const compiled = evm2wasm.compile(code)
      const kernel = new Kernel({
        code: compiled
      })

      try {
        await kernel.run(environment)
      } catch (e) {
        t.true(test.trapped, 'should trap')
      }

      if (!test.trapped) {
        // check the gas used
        const gasUsed = startGas - environment.gasLeft
        t.equals(gasUsed, test.gasUsed, 'should use the correct amount of gas')

        // check the results
        test.result.stack.forEach((item, index) => {
          const sp = index * 32
          const expectedItem = new Uint8Array(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), 32)).reverse()
          const result = new Uint8Array(kernel.interfaceAPI.memory).slice(sp, sp + 32)
          t.equals(result.toString(), expectedItem.toString(), 'should have correct item on stack')
        })
      }
    }
  }
  t.end()
})
