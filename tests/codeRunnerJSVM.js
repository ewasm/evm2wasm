const fs    = require('fs')
const tape  = require('tape')
const VM    = require('ethereumjs-vm')
const async = require('async')
const BN    = require('bn.js')

const dir = './code/'
let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

tape('testing js VM', (t) => {
  async.eachSeries(testFiles, (path, cb0) => {
    let codeTests = require(dir + path)
    async.eachSeries(codeTests, (test, cb1) => {
      t.comment(test.description)
      const vm = new VM()
      vm.runCode({
        code: new Buffer(test.code.slice(2), 'hex'),
        gasLimit: new BN(90000)
      }, (err, results) => {
        // check the results
        const stack = results.runState.stack
        stack.forEach((item, index) => {
          t.equals('0x' + item.toString('hex'), test.result.stack[index])
        })
        cb1()
      })
    }, cb0)
  }, t.end)
})
