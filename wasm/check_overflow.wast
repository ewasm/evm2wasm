(func $check_overflow
  (param $a i64)
  (param $b i64)
  (param $c i64)
  (param $d i64)
  (result i32)

  (local $MAX_INT i64)
  ;; the eighth Mersenne prime,  2^31 - 1
  (set_local $MAX_INT (i64.const 0x7fffffff))

  (if i32 
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
