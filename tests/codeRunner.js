const fs = require('fs')
const cp = require('child_process')
const tape = require('tape')
const evm2wasm = require('../index.js')

const dir = './code/'
let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

tape('testing transcompiler', (t) => {
  testFiles.forEach((path) => {
    let codeTests = require(dir + path)
    codeTests.forEach((test) => {
      const testInstance = buildTest(new Buffer(test.code.slice(2), 'hex'))
      testInstance.exports.main()
      // console.log(new Uint8Array(testInstance.exports.memory))
      t.end()
      process.exit()
        // compile
        // cp.exec(`../deps/sexpr-wasm-prototype/out/sexpr-wasm `)
    })
  })
})

function buildTest (code) {
  const compiled = evm2wasm.compile(code)
  fs.writeFileSync('temp.wast', compiled)
  cp.execSync('../deps/sexpr-wasm-prototype/out/sexpr-wasm ./temp.wast -o ./temp.wasm')
  const opsWasm = fs.readFileSync('./temp.wasm')
  return Wasm.instantiateModule(opsWasm, {print: {i32: print}})
}

function print (i) {
  console.log(i)
}
