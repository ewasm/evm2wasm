const fs = require('fs')
const tape = require('tape')
const Kernel = require('ewasm-kernel')
const KernelInterface = require('ewasm-kernel/interface.js')
const KernelEnvironment = require('ewasm-kernel/environment.js')
const ethUtil = require('ethereumjs-util')
const compiler = require('../index.js')
const dir = `${__dirname}/opcode`

// Transcompiled contracts have their EVM1 memory start at this WASM memory location
const EVM_MEMORY_OFFSET = 33832

let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

tape('testing EVM1 Ops', (t) => {
  testFiles.forEach((path) => {
    let opTest = require(`${dir}/${path}`)
    opTest.forEach((test) => {
      const testEnvironment = new KernelEnvironment()
      const testInterface = new KernelInterface(testEnvironment)
      const testInstance = buildTest(test.op, testInterface)

      // FIXME: have separate `t.test()` for better grouping
      t.comment(`testing ${test.op} ${test.description}`)

      // populate the environment
      if (test.environment) {
        Object.keys(test.environment).forEach((key) => {
          let value = test.environment[key]
          if (key === 'caller')
            value = hexToUint8Array(value, 20)
          else
            throw new Error('Unsupported environment variable')
          testEnvironment[key] = value
        })
      }

      // populate the stack with predefined values
      test.stack.in.forEach((item, index) => {
        item = hexToUint8Array(item)
        setMemory(testInstance, item, index * 32)
      })

      // populate the memory
      if (test.memory) {
        Object.keys(test.memory.in).forEach((offset) => {
            let item = test.memory.in[offset]
            offset |= 0
            offset += EVM_MEMORY_OFFSET
            item = hexToUint8Array(item)
            setMemory(testInstance, item, offset)
        })
      }

      // Runs the opcode. An empty stack must start with the stack pointer at -8.
      // also we have to add 8 to the resulting sp to accommodate for the fact
      // that the sp is pointing to memory segment holding the last stack item
      let sp = (test.stack.in.length - 1) * 32 
      sp = testInstance.exports[test.op](...(test.params || []), sp) + 32
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
            offset += EVM_MEMORY_OFFSET
            const expectedItem = hexToUint8Array(item)
            const result = getMemory(testInstance, offset + index * 32, offset + index * 32 + expectedItem.length)
            t.equals(result.toString(), expectedItem.toString(), `should have the correct memory slot at ${offset}:${index}`)
          })
        })
      }

      // check for EVM return value
      if (test.return) {
        const expectedItem = hexToUint8Array(test.return)
        const result = testEnvironment.returnValue
        t.equals(result.toString(), expectedItem.toString(), 'should have correct return value')
      }
    })
  })
  t.end()
})

function buildTest (op, interface) {
  const funcs = compiler.resolveFunctions(new Set([op]))
  const linked = compiler.buildModule(funcs, [], [op])
  const wasm = compiler.compileWAST(linked)
  return Kernel.codeHandler(wasm, interface)
}

function hexToUint8Array(item, length) {
  return new Uint8Array(ethUtil.setLength(new Buffer(item.slice(2), 'hex'), length || 32)).reverse()
}

function setMemory(instance, value, start) {
  new Uint8Array(instance.exports.memory).set(value, start)
}

function getMemory(instance, start, end) {
  return new Uint8Array(instance.exports.memory).slice(start, end)
}
