const fs = require('fs')
const opsWasm = fs.readFileSync('./wasm/ops.wasm')
const tape = require('tape')
const ethUtil = require('ethereumjs-util')

let testFiles = fs.readdirSync('./tests').filter((name) => name.endsWith('.json'))

// testFiles = ['mul.json']

tape('testing EVM1 Ops', (t) => {
  const testInstance = Wasm.instantiateModule(opsWasm, {print: {i32: print}})

  testFiles.forEach((path) => {
    let opTest = require(`./tests/${path}`)
    opTest.forEach((test) => {
      // populate the stack
      t.comment(`testing ${test.description}`)

      test.stack.in.reverse().forEach((item, index) => {
        item = Uint8Array.from(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), 32)).reverse()
        new Uint8Array(testInstance.exports.memory).set(item, index * 32)
      })
      // run the opcode
      let sp = testInstance.exports[test.op](test.stack.in.length * 32 - 8)
      t.equal((sp + 8) / 32, test.stack.out.length, 'should have corrent number of items on the stack')
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
