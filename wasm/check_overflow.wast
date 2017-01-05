(func $check_overflow
  (param $a i64)
  (param $b i64)
  (param $c i64)
  (param $d i64)
  (result i32)

  (local $MAX_INT i32)
  (set_local $MAX_INT (i32.const -1))

  (if i32 
    (i32.and 
      (i32.and 
        (i64.eqz  (get_local $d))
        (i64.eqz  (get_local $c)))
      (i32.and
        (i64.eqz  (get_local $b))
        (i64.lt_u (get_local $a) (i64.extend_u/i32 (get_local $MAX_INT)))))
      (then
        (return (i32.wrap/i64 (get_local $a))))
      (else 
        (return (get_local $MAX_INT)))))
