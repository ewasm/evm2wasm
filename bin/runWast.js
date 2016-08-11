#!/usr/bin/env node
const cp = require('child_process')
const fs = require('fs')
const path = require('path')
const Kernal = require('ewasm-kernel')

const loc = path.join(process.cwd(), process.argv[2])
cp.execSync(`${__dirname}/../tools/sexpr-wasm-prototype/out/sexpr-wasm  ${loc} -o ./temp.wasm`)
const opsWasm = fs.readFileSync('./temp.wasm')
const instance = Kernal.codeHandler(opsWasm)
let sp = instance.exports.main()

sp = 64
for (;sp > -32 ; sp -= 32) {
  const item = getMemory(instance, sp, sp + 32)
  console.log(new Buffer(item).toString('hex'))
}

function getMemory(instance, start, end) {
  return new Uint8Array(instance.exports.memory).slice(start, end)
}
