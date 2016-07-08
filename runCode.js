const BaseStateTranitions = require('js-prototype')
const evm2wasm = require('./index.js')
const fs = require('fs')
const cp = require('child_process')

module.exports = function (code) {
  const wasm = compile(code)
  return BaseStateTranitions.codeHandler(wasm)
}

/**
 * compiles EVM code to wasm
 * @method compile
 * @param {string} code
 */
function compile(code) {
  // todo add better caching
  const wast = evm2wasm.compile(code)
  fs.writeFileSync('temp.wast', {ethereum: wast})
  cp.execSync('../deps/sexpr-wasm-prototype/out/sexpr-wasm ./temp.wast -o ./temp.wasm')
  return fs.readFileSync('./temp.wasm')
}

