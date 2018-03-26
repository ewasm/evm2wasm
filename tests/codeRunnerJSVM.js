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
      //   console.log(info.opcode.name, info.opcode.fee);
      // })
      vm.runCode({
        data: test.environment.callData,
        code: Buffer.from(test.code.slice(2), 'hex'),
        gasLimit: new BN(90000)
      }, (err, results) => {
        t.equals(results.gasUsed.toNumber(), test.gasUsed, 'should use correct amount of gas')
        // check the results
        // console.log(test.gasUsed);
        console.log(err)

        t.equals(results.exception, 1, 'should not run into exception')

        // check the gas used
        const gasUsed = results.gasUsed.toNumber()
        t.equals(gasUsed, test.gasUsed, 'should have correct gas')

        const stack = results.runState.stack
        t.equal(stack.length, test.result.stack.length, 'should have correct number of items on the stack')

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
