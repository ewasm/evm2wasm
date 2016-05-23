const BN = require('bn.js')
const MAX_INTEGER = new BN('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', 16)

function div (a, b) {
  a = fromSigned(a)
  b = fromSigned(b)

  var r
  if (b.isZero()) {
    r = new Buffer([0])
  } else {
    r = toUnsigned(a.div(b))
  }

  return r
}

const r = div(new BN(-1), new BN(2))
console.log(r)

function fromSigned (num) {
  return new BN(num).fromTwos(256)
}

function toUnsigned (num) {
  return new Buffer(num.toTwos(256).toArray())
}
