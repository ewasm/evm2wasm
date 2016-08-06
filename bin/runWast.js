#!/usr/bin/env node
const cp = require('child_process')
const fs = require('fs')
const path = require('path')
const Kernal = require('ewasm-kernel')

const loc = path.join(process.cwd(), process.argv[2])
cp.execSync(`${__dirname}/../tools/sexpr-wasm-prototype/out/sexpr-wasm  ${loc} -o ./temp.wasm`)
const opsWasm = fs.readFileSync('./temp.wasm')
Kernal.codeHandler(opsWasm)
