(module
  (func $sub
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
    (set_local $a2 (call $sub64 ($a1 $a $carry)))
    (set_local $carry (call $checkoverflow ($a2 $a1 $a)))

    ;; b
    (set_local $b2 (call $sub64 ($b1 $b $carry)))
    (set_local $carry (call $checkoverflow ($b2 $b1 $b)))

    ;; c
    (set_local $c2 (call $sub64 ($c1 $c $carry)))
    (set_local $carry (call $checkoverflow ($c2 $c1 $c)))

    ;; d
    (set_local $d2 (call $add64 ($d1 $d $carry)))
    (set_local $carry (call $checkoverflow ($d2 $d1 $d)))
  )

  ;; check the add result for overflow
  (func $checkOverflow 
    (param $subtrahend i64)
    (param $a i64)
    (param $b i64)
    (result i64)
    (if 
      ;; subtrahend<=a and subtrahend<=b
      (i64.or
        (i64.lt_u (get_local $b) (get_local $subtrahend))
        (i64.lt_u (get_local $a) (get_local $subtrahend)))
      (then 
        (return i64.const 1)
      )
      (else
        (return i64.const 0)
      )
    )
  )

  (func $sub64
    (param $a)
    (param $b)
    (param $carry)
    (result i64)
    (return (i64.sub (get_local $a) (i64.sub (get_local $b) (get_local $carry))))
  )
  (export $add)
)

(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 0)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 1)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 2)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 3)))
