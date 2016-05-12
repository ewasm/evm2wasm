(module
  (func $div
    ;; dividend
    (param $a i64)
    (param $b i64)
    (param $c i64)
    (param $d i64)

    ;; divisor
    (param $a1 i64)
    (param $b1 i64)
    (param $c1 i64)
    (param $d1 i64)

    ;; qutiant
    (param $a2 i64)
    (param $b2 i64)
    (param $c2 i64)
    (param $d2 i64)

    (local $numToShift)
    (local $mask)

    ;; check div by 0
    (if (i64.and (i64.and (i64.and (get_local $a1) (get_local $b1)) (get_local $c1)) (get_local $d1))    
      ;; br
    )

    ;; check if the divsor is larger then the dividend
    (if (i64.lt_u (get_local $a) (get_local $a1) )
      (then
        ;; break
      )  
      (else
        (if (i64.eqz(get_local $a)) 
          (then
            (if (i64.lt_u (get_local $b) (get_local $b1))
              (then
                ;; break
              ) 
              (else 
                (if (i64.eqz(get_local $b)) 
                  (then
                    (if (i64.lt_u (get_local $c) (get_local $c1))
                      (then
                        ;; break 
                      ) 
                      (else 
                        (if (i64.eqz(get_local $c)) 
                          (then
                            (if (i64.lt_u (get_local $d) (get_local $d1))
                              (then
                                ;; break
                              )
                              (else
                                ;; return result
                                (i64.div (get_local $d) (get_local $d1))
                              )
                            )
                          ) 
                        )       
                      )
                    )
                  ) 
                )       
              )
            )
          ) 
        )
      )
    )

    ;; --- 4 block ---
    ;; divisor takes 4 regersters
    ;; shift regerister of divisor as leading empty regesters
    (if (i64.eqz(get_local $a1))
      (then 
        (set_local $numToShift (i64.const 64))
        (if (i64.eqz (get_local $b1))
          (then 
            (set_local $numToShift (i64.add (i64.const 64) (get_local $numToShift)))
            (if (i64.eqz (get_local $c1))
              (then 
                (set_local $numToShift (i64.add (i64.const 64) (get_local $numToShift)))
                ;; TODO return
                (i64.div (get_local $d1) (get_local $d))
              )
              ;; shift two register
              (else
                ;; TODO jump 2 args
              )
            )
          )
          ;; shift one regester 
          ;; b->a, c->b, d->c, null->d
          (else
            (set_local $a (get_local $b1))
            (set_local $b (get_local $c1))
            (set_local $c (get_local $d1))
            (set_local $d (i64.const 0))
          )
        )
      ) 
    )

    ;; shift regesters
    (set_local $numToShift (i64.sub (i64.clz $a) (i64.clz $a1)))
    (if (i64.lt_s (get_local $numToShift) (i64.const 0))
      ;; the divors is bigger than the dividend
      (then 
        ;;exit
      )
      (else
        ;; shift
        (set_local $a1 (i64.shl (get_local $a1) (get_local $numToShift)))
        (set_local $b1 (i64.shl (get_local $b1) (get_local $numToShift)))
        (set_local $c1 (i64.shl (get_local $c1) (get_local $numToShift)))
        (set_local $d1 (i64.shl (get_local $d1) (get_local $numToShift)))
      )
    )

    ;; run on 4 registers 
    (loop $exit $loop
      (if (i64.eqz (get_local $a))
        (then
          ;; break to 3
        )
      )
      (if (i64.lte_u (get_local $a1) (get_local $a))
        (then
          ;; subtract remain = reamin - part1
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

          ;; add the mask result = mask + result 
          (set_local $resultA (call $add64 ($resultA $maskA (i64.const 0))))
          (set_local $carry (call $checkoverflow ($a2 $a1 $a)))

          ;; b
          (set_local $resultB (call $add64 ($resultB $maskB $carry)))
          (set_local $carry (call $checkoverflow ($b2 $b1 $b)))

          ;; c
          (set_local $resultC (call $add64 ($resultC $maskC $carry)))
          (set_local $carry (call $checkoverflow ($c2 $c1 $c)))

          ;; d
          (set_local $resultD (call $add64 ($resultD $maskD $carry)))
        )
      )
      
      ;; part1 = part1 >> 1
      (set_local $a1 (i64.shl (get_local $a1) (i64.const 1)))
      (set_local $b1 (i64.shl (get_local $b1) (i64.const 1)))
      (set_local $c1 (i64.shl (get_local $c1) (i64.const 1)))
      (set_local $d1 (i64.shl (get_local $d1) (i64.const 1)))

      ;; mask = mask >> 1
      (set_local $a1 (i64.shl (get_local $a1) (i64.const 1)))
      (set_local $b1 (i64.shl (get_local $b1) (i64.const 1)))
      (set_local $c1 (i64.shl (get_local $c1) (i64.const 1)))
      (set_local $d1 (i64.shl (get_local $d1) (i64.const 1)))
    )
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
  (export $mul)
)

(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 0)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 1)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 2)))
(assert_test $add((i64.const 1) (i64.const 2) (i64.const 3) (i64.const 4) (i32.const 3)))
