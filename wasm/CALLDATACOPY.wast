(func $CALLDATACOPY
  (param $sp i32)
  (result i32)
  (local $memstart i32)

  (local $writeOffset i32)
  (local $writeOffset0 i64)
  (local $writeOffset1 i64)
  (local $writeOffset2 i64)
  (local $writeOffset3 i64)

  (local $dataOffset i32)
  (local $dataOffset0 i64)
  (local $dataOffset1 i64)
  (local $dataOffset2 i64)
  (local $dataOffset3 i64)

  (local $length i32)
  (local $length0 i64)
  (local $length1 i64)
  (local $length2 i64)
  (local $length3 i64)

  (set_local $memstart (i32.const 33832))

  (set_local $length0 (i64.load (i32.sub (get_local $sp) (i32.const 64))))
  (set_local $length1 (i64.load (i32.sub (get_local $sp) (i32.const 56))))
  (set_local $length2 (i64.load (i32.sub (get_local $sp) (i32.const 48))))
  (set_local $length3 (i64.load (i32.sub (get_local $sp) (i32.const 40))))

  (set_local $dataOffset0 (i64.load (i32.sub (get_local $sp) (i32.const 32))))
  (set_local $dataOffset1 (i64.load (i32.sub (get_local $sp) (i32.const 24))))
  (set_local $dataOffset2 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $dataOffset3 (i64.load (i32.sub (get_local $sp) (i32.const  8))))

  (set_local $writeOffset0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $writeOffset1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $writeOffset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $writeOffset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $length 
             (call $check_overflow (get_local $length0)
                                   (get_local $length1)
                                   (get_local $length2)
                                   (get_local $length3)))
  (set_local $writeOffset
             (call $check_overflow (get_local $writeOffset0)
                                   (get_local $writeOffset1)
                                   (get_local $writeOffset2)
                                   (get_local $writeOffset3)))
  (set_local $dataOffset 
             (call $check_overflow (get_local $dataOffset0)
                                   (get_local $dataOffset1)
                                   (get_local $dataOffset2)
                                   (get_local $dataOffset3)))


  (call $memUseGas (get_local $writeOffset) (get_local $length))
  ;; check for overflow length

  (call_import $callDataCopy 
              (i32.add (get_local $writeOffset) (get_local $memstart))
              (get_local $dataOffset)
              (get_local $length))

  ;; pop 3 stack items
  (return (i32.sub (get_local $sp) (i32.const 96)))
)

(func $check_overflow
  (param $a i64)
  (param $b i64)
  (param $c i64)
  (param $d i64)
  (result i32)

  (local $MAX_INT i64)
  ;; the eighth Mersenne prime,  2^31 - 1
  (set_local $MAX_INT (i64.const 0x7fffffff))

  (if 
    (i32.and 
      (i32.and 
        (i64.eqz  (get_local $d))
        (i64.eqz  (get_local $c)))
      (i32.and 
        (i64.eqz  (get_local $b))
        (i64.lt_u (get_local $a) (get_local $MAX_INT))))
      (then
        (return (i32.wrap/i64 (get_local $a))))
      (else 
        (return (i32.wrap/i64 (get_local $MAX_INT))))))
