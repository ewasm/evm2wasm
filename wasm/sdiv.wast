(module
 ;; (import $print_mem "spectest" "print_mem")
  (import $print_i64 "spectest" "print" (param i64))
  (import $print_i32 "spectest" "print" (param i32))
  (import $print_mem "spectest" "print_mem")
  (export "a" memory)
  (memory 1 1)
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

    (param $memIndex i32)

    ;; quotient
    (local $aq i64)
    (local $bq i64)
    (local $cq i64)
    (local $dq i64)

    ;; mask
    (local $maska i64)
    (local $maskb i64)
    (local $maskc i64)
    (local $maskd i64)

    (local $sign  i64)
    (local $carry i32)
    (local $temp  i64)
    (result i64)

    (set_local $maskd (i64.const 1))
    ;; get the resulting sign
    (set_local $sign (i64.shr_u (i64.xor (get_local $d1) (get_local $d)) (i64.const 63)))

    ;; convert to unsigned value
    (if (i64.eqz (i64.clz (get_local $a)))
      (then
        (set_local $a (i64.xor (get_local $a) (i64.const -1)))
        (set_local $b (i64.xor (get_local $b) (i64.const -1)))
        (set_local $c (i64.xor (get_local $c) (i64.const -1)))
        (set_local $d (i64.xor (get_local $d) (i64.const -1)))

        ;; a = a + 1
        (set_local $d (i64.add (get_local $d) (i64.const 1)))
        (set_local $carry (i64.eqz (get_local $d)))
        (set_local $c (i64.add (get_local $c) (i64.extend_u/i32 (get_local $carry))))
        (set_local $carry (i32.and (i64.eqz (get_local $c)) (get_local $carry)))
        (set_local $b (i64.add (get_local $b) (i64.extend_u/i32 (get_local $carry))))
        (set_local $carry (i32.and (i64.eqz (get_local $b)) (get_local $carry)))
        (set_local $a (i64.add (get_local $a) (i64.extend_u/i32 (get_local $carry))))
      )
    )
    (if (i64.eqz (i64.clz (get_local $a1)))
      (then
        (set_local $a1 (i64.xor (get_local $a1) (i64.const -1)))
        (set_local $b1 (i64.xor (get_local $b1) (i64.const -1)))
        (set_local $c1 (i64.xor (get_local $c1) (i64.const -1)))
        (set_local $d1 (i64.xor (get_local $d1) (i64.const -1)))

        (set_local $d1 (i64.add (get_local $d1) (i64.const 1)))
        (set_local $carry (i64.eqz (get_local $d1)))
        (set_local $c1 (i64.add (get_local $c1) (i64.extend_u/i32 (get_local $carry))))
        (set_local $carry (i32.and (i64.eqz (get_local $c1)) (get_local $carry)))
        (set_local $b1 (i64.add (get_local $b1) (i64.extend_u/i32 (get_local $carry))))
        (set_local $carry (i32.and (i64.eqz (get_local $b1)) (get_local $carry)))
        (set_local $a1 (i64.add (get_local $a1) (i64.extend_u/i32 (get_local $carry))))
      )
    )
    
    (block $main
      ;; check div by 0
      (if (call $isZero (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
        (br $main)
      )

      ;; align bits
      (loop $done $loop
        ;; align bits;
        (if (i32.or (i64.eq (i64.clz (get_local $a1)) (i64.clz (get_local $a))) (call $gte (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $a) (get_local $b) (get_local $c) (get_local $d)))
          (br $done)
        )

        ;; divisor = divisor << 1
        (set_local $a1 (i64.add (i64.shl (get_local $a1) (i64.const 1)) (i64.shr_u (get_local $b1) (i64.const 63))))
        (set_local $b1 (i64.add (i64.shl (get_local $b1) (i64.const 1)) (i64.shr_u (get_local $c1) (i64.const 63))))
        (set_local $c1 (i64.add (i64.shl (get_local $c1) (i64.const 1)) (i64.shr_u (get_local $d1) (i64.const 63))))
        (set_local $d1 (i64.shl (get_local $d1) (i64.const 1)))

        ;; mask = mask << 1
        (set_local $maska (i64.add (i64.shl (get_local $maska) (i64.const 1)) (i64.shr_u (get_local $maskb) (i64.const 63))))
        (set_local $maskb (i64.add (i64.shl (get_local $maskb) (i64.const 1)) (i64.shr_u (get_local $maskc) (i64.const 63))))
        (set_local $maskc (i64.add (i64.shl (get_local $maskc) (i64.const 1)) (i64.shr_u (get_local $maskd) (i64.const 63))))
        (set_local $maskd (i64.shl (get_local $maskd) (i64.const 1)))

        (br $loop)
      )

      (loop $done $loop
        ;; loop while mask != 0
        (if (call $isZero (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd))
          (br $done)
        )
        ;; if dividend >= divisor
        (if (call $gte (get_local $a) (get_local $b) (get_local $c) (get_local $d) (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
          (then
            ;; dividend = dividend - divisor
            (set_local $carry (i64.lt_u (get_local $d) (get_local $d1)))
            (set_local $d     (i64.sub  (get_local $d) (get_local $d1)))
            (set_local $temp  (i64.sub  (get_local $c) (i64.extend_u/i32 (get_local $carry))))
            (set_local $carry (i64.gt_u (get_local $temp) (get_local $c)))
            (set_local $c     (i64.sub  (get_local $temp) (get_local $c1)))
            (set_local $carry (i32.or   (i64.gt_u (get_local $c) (get_local $temp)) (get_local $carry)))
            (set_local $temp  (i64.sub  (get_local $b) (i64.extend_u/i32 (get_local $carry))))
            (set_local $carry (i64.gt_u (get_local $temp) (get_local $b)))
            (set_local $b     (i64.sub  (get_local $temp) (get_local $b1)))
            (set_local $carry (i32.or   (i64.gt_u (get_local $b) (get_local $temp)) (get_local $carry)))
            (set_local $a     (i64.sub  (i64.sub (get_local $a) (i64.extend_u/i32 (get_local $carry))) (get_local $a1)))

            ;; result = result + mask
            (set_local $dq    (i64.add  (get_local $maskd) (get_local $dq)))
            (set_local $carry (i64.lt_u (get_local $dq) (get_local $maskd)))
            (set_local $temp  (i64.add  (get_local $cq) (i64.extend_u/i32 (get_local $carry))))
            (set_local $carry (i64.lt_u (get_local $temp) (get_local $cq)))
            (set_local $cq    (i64.add  (get_local $maskc) (get_local $temp)))
            (set_local $carry (i32.or   (i64.lt_u (get_local $cq) (get_local $maskc)) (get_local $carry)))
            (set_local $temp  (i64.add  (get_local $bq) (i64.extend_u/i32 (get_local $carry))))
            (set_local $carry (i64.lt_u (get_local $temp) (get_local $bq)))
            (set_local $bq    (i64.add  (get_local $maskb) (get_local $temp)))
            (set_local $carry (i32.or   (i64.lt_u (get_local $bq) (get_local $maskb)) (get_local $carry)))
            (set_local $aq    (i64.add  (get_local $maska) (i64.add (get_local $aq) (i64.extend_u/i32 (get_local $carry)))))
          )
        )
        ;; divisor = divisor >> 1
        (set_local $d1 (i64.add (i64.shr_u (get_local $d1) (i64.const 1)) (i64.shl (get_local $c1) (i64.const 63))))
        (set_local $c1 (i64.add (i64.shr_u (get_local $c1) (i64.const 1)) (i64.shl (get_local $b1) (i64.const 63))))
        (set_local $b1 (i64.add (i64.shr_u (get_local $b1) (i64.const 1)) (i64.shl (get_local $a1) (i64.const 63))))
        (set_local $a1 (i64.shr_u (get_local $a1) (i64.const 1)))

        ;; mask = mask >> 1
        (set_local $maskd (i64.add (i64.shr_u (get_local $maskd) (i64.const 1)) (i64.shl (get_local $maskc) (i64.const 63))))
        (set_local $maskc (i64.add (i64.shr_u (get_local $maskc) (i64.const 1)) (i64.shl (get_local $maskb) (i64.const 63))))
        (set_local $maskb (i64.add (i64.shr_u (get_local $maskb) (i64.const 1)) (i64.shl (get_local $maska) (i64.const 63))))
        (set_local $maska (i64.shr_u (get_local $maska) (i64.const 1)))
        (br $loop)
      )
    );; end of main

    ;; convert to singed
    (if (i64.eqz (i64.clz (get_local $aq)))
      (then
        (set_local $aq (i64.xor (get_local $aq) (i64.const -1)))
        (set_local $bq (i64.xor (get_local $bq) (i64.const -1)))
        (set_local $cq (i64.xor (get_local $cq) (i64.const -1)))
        (set_local $dq (i64.xor (get_local $dq) (i64.const -1)))

        (set_local $dq (i64.add (get_local $dq) (i64.const 1)))
        (set_local $cq (i64.add (get_local $cq) (i64.extend_u/i32 (i64.eqz (get_local $dq)))))
        (set_local $bq (i64.add (get_local $bq) (i64.extend_u/i32 (i64.eqz (get_local $cq)))))
        (set_local $aq (i64.add (get_local $aq) (i64.extend_u/i32 (i64.eqz (get_local $bq)))))
      )
    )

    (i64.store (i32.const 0)  (get_local $aq))
    (i64.store (i32.const 8)  (get_local $bq))
    (i64.store (i32.const 16) (get_local $cq))
    (i64.store (i32.const 24) (get_local $dq))

    ;; add section done
    (i64.load  (get_local $memIndex))
  )

  (func $isZero
    (param i64)
    (param i64)
    (param i64)
    (param i64)
    (result i32)
    (i64.eqz (i64.or (i64.or (i64.or (get_local 0) (get_local 1)) (get_local 2)) (get_local 3)))
  )

  ;; is a less than or equal to b // a >= b
  (func $gte 
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    ;; a0 > b0 || (a0 == b0 && (a1 > b1 || (a1 == b1 && (a2 > b2 || (a2 == b2 && a3 >= b3 ) ))))
    (i32.or  (i64.gt_u (get_local $a0) (get_local $b0)) ;; a0 > b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0))  
    (i32.or  (i64.gt_u (get_local $a1) (get_local $b1)) ;; a1 > b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.gt_u (get_local $a2) (get_local $b2)) ;; a2 > b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2))
             (i64.ge_u (get_local $a3) (get_local $b3))))))))
  )
  (export "div" $div)
)
;; 2^256 / 0  
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 0))  (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 8))  (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 16)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 24)) (i64.const 0))

;; 2^256 / 2^256 
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 0)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 8)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 16)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 24)) (i64.const 1))

;; -1 / 2
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 0)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 8)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 16)) (i64.const 0))
(assert_return (invoke "div" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 24)) (i64.const 0))
