const BN = require('bn.js')
const MAX_INTEGER = new BN('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', 16)

function div (a, b) {
  a = fromSigned(a)
  b = fromSigned(b)
  console.log(a.toString());

  var r
  if (b.isZero()) {
    r = new Buffer([0])
  } else {
    console.log(a.div(b).toString(16))
    r = toUnsigned(a.div(b))
  }

  return r
}

const r = div( new BN('8000000000000000000000000000000000000000000000000000000000000001', 16),MAX_INTEGER)
console.log(r.toString(16))

function fromSigned (num) {
  return new BN(num).fromTwos(256)
}

function toUnsigned (num) {
  return num.toTwos(256)
}
