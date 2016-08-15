const fs = require('fs')
const tape = require('tape')
const VM = require('ethereumjs-vm')
const async = require('async')
const BN = require('bn.js')
const argv = require('minimist')(process.argv.slice(2))
const dir = './code/'
let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

// run a single file
if (argv.file) {
  testFiles = [argv.file]
}

tape('testing js VM', (t) => {
  async.eachSeries(testFiles, (path, cb0) => {
    let codeTests = require(dir + path)
    async.eachSeries(codeTests, (test, cb1) => {
      t.comment(test.description)
      const vm = new VM()
        // vm.on('step', (info) => {
        //   console.log(info.opcode.name);
        // })
      vm.runCode({
        code: new Buffer(test.code.slice(2), 'hex'),
        gasLimit: new BN(90000)
      }, (err, results) => {
        // test.gasUsed = results.gasUsed.toNumber()
          // check the results
        console.log(test.gasUsed);
        const stack = results.runState.stack
        test.result.stack.forEach((item, index) => {
          t.equals('0x' + stack[index].toString('hex'), item)
        })
        cb1()
      })
    }, () => {
      // fs.writeFileSync(dir + path, JSON.stringify(codeTests, null, 2))
      cb0()
    })
  }, t.end)
})
