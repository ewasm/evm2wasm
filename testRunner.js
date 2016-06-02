const fs = require('fs')
const opsWasm = fs.readFileSync('./wasm/ops.wasm')
const testInstance = Wasm.instantiateModule(opsWasm)
const tape = require('tape')

let testFiles = fs.readdirSync('./tests').filter((name) => name.endsWith('.json'))

testFiles = ['add.json']

tape('testing EVM1 Ops', (t) => {
  testFiles.forEach((path) => {
    const opTest = require(`./tests/${path}`)
    opTest.forEach((test) => {
      // populate the stack
      t.comment(`testing ${test.op}`)
      test.stack.in.forEach((item, index) => {
        item = Uint8Array.from(new Buffer(item.slice(2))).reverse()
        new Uint8Array(testInstance.exports.memory).set(item, index * 32)
      })

      // run the opcode
      let sp = testInstance.exports[test.op](0)
      t.equal(sp / 32, test.stack.out.length, 'should have corrent number of items on the stack')
      sp = 0

      // check the results
      test.stack.out.forEach((item, index) => {
        const expectedItem = Uint8Array.from(new Buffer(item.slice(2))).reverse()
        const result = testInstance.exports.memory.slice(sp, sp = sp + 32)
        t.deepEquals(result, expectedItem, 'should have correct item on stack')
      })
    })
  })
})
