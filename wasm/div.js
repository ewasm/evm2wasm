const BN = require('bn.js')
const MAX_INTEGER = new BN('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', 16)

function div (a, b) {
  a = new BN(a)
  b = new BN(b)
  var r
  if (b.isZero()) {
    r = [0]
  } else {
    r = a.div(b)
  }
  return r
}

const r = div(new BN(MAX_INTEGER), 2)
console.log(r.toString(16))
