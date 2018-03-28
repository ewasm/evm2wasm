const fs = require('fs')
const tape = require('tape')
const Vertex = require('merkle-trie')
const evm2wasm = require('../index.js')
const ethUtil = require('ethereumjs-util')
const Kernel = require('ewasm-kernel')
const Message = require('ewasm-kernel/message')
const Block = require('ewasm-kernel/deps/block')
const blockchain = require('ewasm-kernel/fakeBlockChain')
const Address = require('ewasm-kernel/deps/address')

const WasmAgent = require('ewasm-kernel/wasmDebugAgent')
const codeHandler = require('ewasm-kernel/codeHandler')
const argv = require('minimist')(process.argv.slice(2))

const dir = `${__dirname}/code/`
let testFiles

codeHandler.handlers.wasm.init = (code) => {
  return new WasmAgent(code)
}

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

      const state = new Vertex()
      const message = new Message()

      const accountAddress = ['accounts', test.environment.address, 'code']
      const startGas = message.gas = 90000
      message.data = Buffer.from(test.message.data.slice(2), 'hex')
      message.from = ['accounts', test.message.from]

      const block = new Block()
      block.header.coinbase = new Address(test.environment.coinbase)

      const code = Buffer.from(test.code.slice(2), 'hex')

      state.set('block', new Vertex({
        value: block
      }))

      state.set('blockchain', new Vertex({
        value: blockchain
      }))

      state.set(accountAddress, new Vertex({
        value: code
      }))

      const {
        buffer: compiled
      } = await evm2wasm.evm2wasm(code, {
        inlineOps: true,
        wabt: false
      })

      const startingState = await state.get(accountAddress)
      const kernel = new Kernel({
        code: compiled,
        state: startingState,
        codeHandler: codeHandler
      })

      try {
        await kernel.recieve(message)
      } catch (e) {
        t.true(test.trapped, 'should trap')
      }

      if (!test.trapped) {
        // check the gas used
        const gasUsed = startGas - message.gas
        t.equals(gasUsed, test.gasUsed, 'should use the correct amount of gas')

        // check the results
        test.result.stack.forEach((item, index) => {
          const sp = index * 32
          const expectedItem = new Uint8Array(ethUtil.setLength(Buffer.from(item.slice(2), 'hex'), 32)).reverse()
          const result = new Uint8Array(kernel._vm.api.memory()).slice(sp, sp + 32)
          t.equals(result.toString(), expectedItem.toString(), 'should have correct item on stack')
        })
      }
    }
  }
  t.end()
})
