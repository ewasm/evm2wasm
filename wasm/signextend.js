  SIGNEXTEND: function (k, runState) {
    k = new BN(k)
    var extendOnes = false

    if (k.cmpn(31) <= 0) {
      k = k.toNumber()

      var val = new Buffer(utils.setLengthLeft(runState.stack.pop(), 32))

      if (val[31 - k] & 0x80) {
        extendOnes = true
      }

      // 31-k-1 since k-th byte shouldn't be modified
      for (var i = 30 - k; i >= 0; i--) {
        val[i] = extendOnes ? 0xff : 0
      }

      return val
    }
  }
