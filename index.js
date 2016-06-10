const opcodes = require('ethereumjs-vm/lib/opcodes')

function compile (evmCode) {
}

/**
 * 1) count instuctions for PC
 */
// function compileSegment (segment) {
//   const func = new wasm.func()
//     segment.forEach((op) => {
//       const wasmEq = conversionTable(op)
//       func.add(wasmEq)
//   })

//   func.end()
// }

const code = require('./tests/add.json').code
const result = compile(code)
console.log(result)

// remap code hashes
// pull original code; if code is not wasm try to convert it. Transpiler will 
// need to be written in wasm
// TRADE OFF 
//  if you have polifilly 
//
// transcompiling create code; can be done at runtime.
// how to store old code? just use prefix
// store the old code in mem storage. 
//  how to protect?
//   use a longer or shorter path then the current contracts have access to
//   transcompiler contract
//    which then get the code and run its
//    extra cost first time calling it
