const fs = require('fs')
const tape = require('tape')
const evm2wasm = require('../index.js')
const ethUtil = require('ethereumjs-util')
const Kernel = require('ewasm-kernel')
const Enviroment = require('ewasm-kernel/environment')
const Interface = require('ewasm-kernel/interface')
const argv = require('minimist')(process.argv.slice(2))

const dir = `${__dirname}/code/`
let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

// run a single file
if (argv.file) {
  testFiles = [argv.file]
}

tape('testing transcompiler', (t) => {
  testFiles.forEach((path) => {
    t.comment(path)
    let codeTests = require(dir + path)
    codeTests.forEach((test) => {
      t.comment(test.description)

      const environment = new Enviroment()
      const startGas = environment.gasLeft
      const ethInterface = new Interface(environment)
      let testInstance
      try {
        testInstance = buildTest(test.code, ethInterface)
      } catch (e) {
        t.fail('WASM exception: ' + e)
        return
      }
      // check the gas used
      const gasUsed = startGas - environment.gasLeft
      t.equals(gasUsed, test.gasUsed, 'should have correct gas')

      // check the results
      test.result.stack.forEach((item, index) => {
        const sp = index * 32
        const expectedItem = new Uint8Array(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), 32)).reverse()
        const result = new Uint8Array(testInstance.exports.memory).slice(sp, sp + 32)
        t.equals(result.toString(), expectedItem.toString(), 'should have correct item on stack')
      })
    })
  })
  t.end()
})

function buildTest (code, env) {
  code = new Buffer(code.slice(2), 'hex')
  const compiled = evm2wasm.compile(code)
  return new Kernel().codeHandler(compiled, env)
}
