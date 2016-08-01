const fs = require('fs')
const tape = require('tape')
const Kernel = require('ewasm-kernel')
const ethUtil = require('ethereumjs-util')
const compiler = require('../index.js')
const dir = `${__dirname}/opcode`

let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

tape('testing EVM1 Ops', (t) => {
  testFiles.forEach((path) => {
    let opTest = require(`${dir}/${path}`)
    opTest.forEach((test) => {
      const testInstance = buildTest(test.op)
      t.comment(`testing ${test.description}`)

      // populate the stack with predefined values
      test.stack.in.reverse().forEach((item, index) => {
        item = hexToUint8Array(item)
        setMemory(testInstance, item, index * 32)
      })

      // populate the memory
      if (test.memory) {
        Object.keys(test.memory.in).forEach((offset) => {
          test.memory.in[offset].forEach((item, index) => {
            offset |= 0
            item = hexToUint8Array(item)
            setMemory(testInstance, item, offset + index * 32)
          })
        })
      }

      // Runs the opcode. An empty stack must start with the stack pointer at -8.
      // also we have to add 8 to the resulting sp to accommodate for the fact
      // that the sp is pointing to memory segment holding the last stack item
      let sp = testInstance.exports[test.op](test.stack.in.length * 32 - 8) + 8
      t.equal(sp / 32, test.stack.out.length, 'should have corrent number of items on the stack')
      sp = 0

      // compare the output stack against the predefined values
      test.stack.out.forEach((item, index) => {
        const expectedItem = hexToUint8Array(item)
        const result = getMemory(testInstance, sp, sp = sp + 32)
        t.equals(result.toString(), expectedItem.toString(), 'should have correct item on stack')
      })

      // check the memory
      if (test.memory) {
        Object.keys(test.memory.out).forEach((offset) => {
          test.memory.out[offset].forEach((item, index) => {
            offset |= 0
            const expectedItem = hexToUint8Array(item)
            const result = getMemory(testInstance, offset + index * 32, offset + index * 32 + expectedItem.length)
            t.equals(result.toString(), expectedItem.toString(), `should have the correct memory slot at ${offset}:${index}`)
          })
        })
      }

    })
  })
  t.end()
})

function buildTest (op) {
  const funcs = compiler.resolveFunctions(new Set([op]))
  const linked = compiler.buildModule(funcs, [], [op])
  const wasm = compiler.compileWAST(linked)
  return Kernel.codeHandler(wasm)
}

function hexToUint8Array(item, length) {
  return new Uint8Array(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), 32)).reverse()
}

function setMemory(instance, value, start) {
  new Uint8Array(instance.exports.memory).set(value, start)
}

function getMemory(instance, start, end) {
  return new Uint8Array(instance.exports.memory).slice(start, end)
}
