const util = require('util')
const fs = require('fs')
const cp = require('child_process')

exports.compile = function (wast) {
  return util.promisify(fs.writeFile)(`${__dirname}/temp.wast`, wast)
    .then(() => {
      return util.promisify(cp.exec)(`${__dirname}/tools/wabt/out/wat2wasm ${__dirname}/temp.wast -o ${__dirname}/temp.wasm`)
    })
    .then(() => {
      return util.promisify(fs.readFile)(`${__dirname}/temp.wasm`)
    })
}
