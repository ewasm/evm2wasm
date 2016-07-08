const fs       = require('fs')
const cp       = require('child_process')
const tape     = require('tape')
const evm2wasm = require('../index.js')
const ethUtil  = require('ethereumjs-util')

const dir = './code/'
let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

tape('testing transcompiler', (t) => {
  testFiles.forEach((path) => {
    let codeTests = require(dir + path)
    codeTests.forEach((test) => {
      t.comment(test.description)
      const testInstance = buildTest(test.code)
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

function buildTest (code) {
  code = new Buffer(code.slice(2), 'hex')
  const compiled = evm2wasm.compile(code)
  fs.writeFileSync('temp.wast', compiled)
  cp.execSync('../deps/sexpr-wasm-prototype/out/sexpr-wasm ./temp.wast -o ./temp.wasm')
  const opsWasm = fs.readFileSync('./temp.wasm')
  return Wasm.instantiateModule(opsWasm, {print: {i32: print}})
}

function print (i) {
  console.log(i)
}
