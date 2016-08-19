const fs = require('fs')
const path = require('path')

const files = fs.readdirSync(__dirname).filter((file) => file.endsWith('.json'))

files.forEach((file) => {
  const json = require(path.join(__dirname, '/') + file)
  for (let testKey in json) {
    const test = json[testKey]
    delete test.state
    if (test.stack) {
      test.in = {
        'stack': test.stack.in
      }
      test.out = {
        'stack': test.stack.out
      }
      delete test.stack
    }
    if (test.memory) {
      test.in['memory'] = test.memory.in
      test.out['memory'] = test.memory.out
      delete test.memory
    }

    if (!test.environment) {
      test.environment = {}
    }

    const evn = test.environment

    if (!evn.callData) {
      evn.callData = '0x00'
    }

    if (!evn.caller) {
      evn.caller = '0x0000000000000000000000000000000000000000'
    }
    if (!evn.address) {
      evn.address = '0x0000000000000000000000000000000000000000'
    }
    if (!evn.coinbase) {
      evn.coinbase = '0x0000000000000000000000000000000000000000'
    }
  }
  console.log(file)
  fs.writeFileSync(path.join(__dirname, '/') + file, JSON.stringify(json, null, 2))
})
