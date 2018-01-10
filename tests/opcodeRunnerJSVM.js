// var runState = {
//   stateManager: stateManager,
//   returnValue: false,
//   stopped: false,
//   vmError: false,
//   suicideTo: undefined,
//   programCounter: 0,
//   opCode: undefined,
//   opName: undefined,
//   gasLeft: new BN(opts.gasLimit),
//   gasLimit: new BN(opts.gasLimit),
//   gasPrice: opts.gasPrice,
//   memory: [],
//   memoryWordCount: 0,
//   stack: [],
//   logs: [],
//   validJumps: [],
//   gasRefund: new BN(0),
//   highestMemCost: new BN(0),
//   depth: opts.depth || 0,
//   suicides: opts.suicides || {},
//   block: block,
//   callValue: opts.value || new BN(0),
//   address: opts.address || utils.zeros(32),
//   caller: opts.caller || utils.zeros(32),
//   origin: opts.origin || opts.caller || utils.zeros(32),
//   callData: opts.data || Buffer.from([0]),
//   code: opts.code,
//   populateCache: opts.populateCache === undefined ? true : opts.populateCache,
//   enableHomestead: this.opts.enableHomestead === undefined ? block.isHomestead() : this.opts.enableHomestead // this == vm
// }
const fs = require('fs')
const tape = require('tape')
const ethUtil = require('ethereumjs-util')
const dir = `${__dirname}/opcode`
const opFunc = require('ethereumjs-vm/lib/opFns.js')
const BN = require('bn.js')
const argv = require('minimist')(process.argv.slice(2))

let testFiles = fs.readdirSync(dir).filter((name) => name.endsWith('.json'))

// run a single file
if (argv.file) {
  testFiles = [argv.file]
}

tape('testing EVM1 Ops', (t) => {
  testFiles.forEach((path) => {
    let opTest = require(`${dir}/${path}`)
    opTest.forEach((test) => {
      // FIXME: have separate `t.test()` for better grouping
      t.comment(`testing ${test.op} ${test.description}`)

      // populate the stack with predefined values
      const stack = test.in.stack.map((i) => Buffer.from(i.slice(2), 'hex'))
      const startGas = '100000000000000000'

      const runState = {
        memoryWordCount: 0,
        memory: [],
        stack: stack,
        opCode: parseInt(test.value),
        highestMemCost: new BN(0),
        gasLeft: new BN(startGas),
        caller: test.environment.caller,
        callData: ethUtil.toBuffer(test.environment.callData)
      }

      // populate the memory
      if (test.in.memory) {
        for (let item in test.in.memory) {
          const memIn = Buffer.from(test.in.memory[item].slice(2), 'hex')
          runState.memory.splice(item, 32, ...memIn)
        }
      }

      // Runs the opcode.
      const noStack = new Set(['DUP', 'SWAP'])
      let args = []
      if (noStack.has(test.op)) {
        args = [runState]
      } else {
        args = stack.slice()
        args.reverse()
        args.push(runState)
        runState.stack = []
      }

      let result
      try {
        result = opFunc[test.op](...args)
      } catch (e) {
        t.fail('JSVM exception: ' + e)
        return
      }

      if (result) {
        runState.stack.push(result)
      }

      // check that gasUsed
      if (test.out.gasUsed) {
        t.equals(new BN(startGas).sub(runState.gasLeft).toNumber(), test.out.gasUsed, 'should use the correct amount of gas')
      }

      test.out.stack.forEach((item, index) => {
        t.equals('0x' + ethUtil.setLength(runState.stack[index], 32).toString('hex'), item, 'stack items should be equal')
      })

      // check the memory
      if (test.out.memory) {
        // TODO
      }

      // check for EVM return value
      if (test.out.return) {
        // TODO
      }
    })
  })
  t.end()
})
