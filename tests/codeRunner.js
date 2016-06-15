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
      const result = evm2wasm(new Buffer(test.code.slice(2), 'hex'))
      console.log(result)
      fs.writeFile(`${dir}${path}.wast`, result, () => {
        t.end()
        process.exit()
        // compile
        // cp.exec(`../deps/sexpr-wasm-prototype/out/sexpr-wasm `)
      })
    })
  })
})
