(func $check_overflow_i64
  (param $a i64)
  (param $b i64)
  (param $c i64)
  (param $d i64)
  (result i64)

  (if i64
    (i32.and 
      (i32.and 
        (i64.eqz  (get_local $d))
        (i64.eqz  (get_local $c)))
      (i64.eqz  (get_local $b)))
    (then
      (return (get_local $a)))
    (else 
      (return (i64.const 0xffffffffffffffff)))))
