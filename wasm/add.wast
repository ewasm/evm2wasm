(module
  (func $add
    (param $a i64)
    (param $b i64)
    (param $c i64)
    (param $d i64)

    (param $a1 i64)
    (param $b1 i64)
    (param $c1 i64)
    (param $d1 i64)

    (param $a2 i64)
    (param $b2 i64)
    (param $c2 i64)
    (param $d2 i64)

    (param $carry i32)
    (result $64)

    ;; a
    (set_local $a2 (call $add64 ($a1 $a $carry)))
    (set_local $carry (call $checkoverflow ($a2 $a1 $a)))

    ;; b
    (set_local $b2 (call $add64 ($b1 $b $carry)))
    (set_local $carry (call $checkoverflow ($b2 $b1 $b)))

    ;; c
    (set_local $c2 (call $add64 ($c1 $c $carry)))
    (set_local $carry (call $checkoverflow ($c2 $c1 $c)))

    ;; d
    (set_local $d2 (call $add64 ($d1 $d $carry)))
  )

  ;; check the add result for overflow
  (func $checkOverflow 
    (param $sum i64)
    (param $a i64)
    (param $b i64)
    (result i64)
    (if 
      ;; sum>=a and sum>=b
      ;; need to check both since we are add a carry bit as well
      (i64.or 
        (i64.lt_u (get_local $sum) (get_local $b))
        (i64.lt_u (get_local $sum) (get_local $a)))
      (then 
        (return i64.const 1)
      )
      (else
        (return i64.const 0))))

  (func $add64
    (param $a)
    (param $b)
    (param $carry)
    (result i64)
    (return (i64.add (get_local $a) (i64.add (get_local $b) (get_local $carry))))
  )
  (export $add)
)

(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 0)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 1)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 2)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 3)))
