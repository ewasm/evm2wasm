const fs = require('fs')
const cp = require('child_process')
const tape = require('tape')
const Kernel   = require('ewasm-kernel')
const ethUtil = require('ethereumjs-util')
const compiler = require('../index.js')
const dir = `${__dirname}/opcode`

let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

tape('testing EVM1 Ops', (t) => {
  testFiles.forEach((path) => {
    let opTest = require(`${dir}/${path}`)
    opTest.forEach((test) => {
      const testInstance = buildTest(test.op)
      // populate the stack
      t.comment(`testing ${test.description}`)
      test.stack.in.reverse().forEach((item, index) => {
        item = Uint8Array.from(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), 32)).reverse()
        new Uint8Array(testInstance.exports.memory).set(item, index * 32)
      })
      // run the opcode
      let sp = testInstance.exports[test.op](test.stack.in.length * 32)
      // console.log(sp);
      t.equal(sp / 32, test.stack.out.length, 'should have corrent number of items on the stack')
      sp = 0
      // check the results
      test.stack.out.forEach((item, index) => {
        const expectedItem = new Uint8Array(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), 32)).reverse()
        const result = new Uint8Array(testInstance.exports.memory).slice(sp, sp = sp + 32)
        t.equals(result.toString(), expectedItem.toString(), 'should have correct item on stack')
      })
    })
  })
  t.end()
})

function print (i) {
  console.log(i)
}

function printMem (i) {
  console.log(i)
}

function buildTest (op) {
  const funcs = compiler.resolveFunctions(new Set([op]))
  const linked = compiler.buildModule(funcs, [], [op])
  const wasm = compiler.compileWAST(linked)
  return Kernel.codeHandler(wasm)
}
