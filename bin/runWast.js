#!/usr/bin/env node
const ethUtil = require('ethereumjs-util')
const cp = require('child_process')
const fs = require('fs')
const path = require('path')

const loc = path.join(process.cwd(), process.argv[2])
cp.execSync(`${__dirname}/../tools/sexpr-wasm-prototype/out/sexpr-wasm  ${loc} -o ./temp.wasm`)
const tempWasm = fs.readFileSync('./temp.wasm')

const mod = WebAssembly.Module(tempWasm)
const instance = WebAssembly.Instance(mod)

const val = instance.exports.main()
console.log(ethUtil.toBuffer(val).toString('hex'))

