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
          if (key === 'caller' || key === 'address')
            value = hexToUint8Array(value, 20)
          else
            throw new Error('Unsupported environment variable')
          testEnvironment[key] = value
        })
      }

      // populate the stack with predefined values
      test.in.stack.forEach((item, index) => {
        item = hexToUint8Array(item)
        setMemory(testInstance, item, index * 32)
      })

      // populate the memory
      if (test.in.memory) {
        Object.keys(test.in.memory).forEach((offset) => {
            let item = test.in.memory[offset]
            offset |= 0
            offset += EVM_MEMORY_OFFSET
            item = hexToUint8Array(item)
            setMemory(testInstance, item, offset)
        })
      }

      // Runs the opcode. An empty stack must start with the stack pointer at -8.
      // also we have to add 8 to the resulting sp to accommodate for the fact
      // that the sp is pointing to memory segment holding the last stack item
      let sp = (test.in.stack.length - 1) * 32 
      sp = testInstance.exports[test.op](...(test.params || []), sp) + 32
      t.equal(sp / 32, test.out.stack.length, 'should have correct number of items on the stack')
      sp = 0

      // compare the output stack against the predefined values
      test.out.stack.forEach((item, index) => {
        const expectedItem = hexToUint8Array(item)
        const result = getMemory(testInstance, sp, sp = sp + 32)
        t.equals(result.toString(), expectedItem.toString(), 'should have correct item on stack')
      })

      // check the memory
      if (test.out.memory) {
        Object.keys(test.out.memory).forEach((offset) => {
            offset |= 0
            const item = test.out.memory[offset]
            const expectedItem = hexToUint8Array(item)
            offset += EVM_MEMORY_OFFSET
            const result = getMemory(testInstance, offset, offset + expectedItem.length)
            t.equals(result.toString(), expectedItem.toString(), `should have the correct memory slot at ${offset}`)
        })
      }

      // check for EVM return value
      if (test.out.return) {
        const expectedItem = hexToUint8Array(test.out.return)
        const result = testEnvironment.returnValue
        t.equals(result.toString(), expectedItem.toString(), 'should have correct return value')
      }

      if (test.out.gasUsed) {
        t.equals(-testEnvironment.gasLimit, test.out.gasUsed, 'should have used the correct amount of gas')
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
