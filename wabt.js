const util = require('util')
const fs = require('fs')
const cp = require('child_process')

exports.compile = function (wast, testName) {
  return util.promisify(fs.writeFile)(`${__dirname}/tmp/${testName}.wast`, wast)
    .then(() => {
      return util.promisify(cp.exec)(`${__dirname}/tools/wabt/bin/wat2wasm ${__dirname}/tmp/${testName}.wast -o ${__dirname}/tmp/${testName}.wasm`)
    })
    .then(() => {
      return util.promisify(fs.readFile)(`${__dirname}/tmp/${testName}.wasm`)
    })
}
