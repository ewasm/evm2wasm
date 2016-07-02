const cp = require('child_process')
const fs = require('fs')
const path = require('path')

const loc = path.join(process.cwd(), process.argv[2])

cp.execSync(`../deps/sexpr-wasm-prototype/out/sexpr-wasm  ${loc} -o ./temp.wasm`)
const opsWasm = fs.readFileSync('./temp.wasm')
const instance = Wasm.instantiateModule(opsWasm, {
  spectest: {
    print: print,
    printMem: printMem
  }
})

instance.exports.main()

function print (i) {
  console.log(i)
}

function printMem (i) {
  console.log('--- mem---');
  const mem = new Uint8Array(instance.exports.memory).slice(0, 128).join('')
  console.log(mem)
}

