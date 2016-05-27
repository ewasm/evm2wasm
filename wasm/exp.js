const BN = require('bn.js')
const MAX_INTEGER = new BN('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', 16)
const TWO_POW256 = new BN('10000000000000000000000000000000000000000000000000000000000000000', 16)

function exp (base, exponent) {
  base = new BN(base)
  exponent = new BN(exponent)
  var m = BN.red(TWO_POW256)
  var result

  base = base.toRed(m)

  if (!exponent.isZero()) {
    // var bytes = 1 + logTable(exponent)
    // subGas(runState, new BN(bytes).muln(fees.expByteGas.v))
    result = new Buffer(base.redPow(exponent).toArray())
  } else {
    result = new Buffer([1])
  }

  return result
}

const r = exp(new BN(2), MAX_INTEGER)
console.log(r)

// if i don't it will be slow if i
