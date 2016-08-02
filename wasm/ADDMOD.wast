(func $ADDMOD
  (param $sp i32)
  (result i32)
  (local $a i64)
  (local $b i64)
  (local $c i64)
  (local $d i64)

  (local $a1 i64)
  (local $b1 i64)
  (local $c1 i64)
  (local $d1 i64)

  (local $moda i64)
  (local $modb i64)
  (local $modc i64)
  (local $modd i64)

  (local $carry i64)

  ;; load args from the stack
  (set_local $a (i64.load (get_local $sp)))
  (set_local $b (i64.load (i32.sub (get_local $sp) (i32.const 8))))
  (set_local $c (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $d (i64.load (i32.sub (get_local $sp) (i32.const 24))))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $a1 (i64.load (get_local $sp)))
  (set_local $b1 (i64.load (i32.sub (get_local $sp) (i32.const 8))))
  (set_local $c1 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $d1 (i64.load (i32.sub (get_local $sp) (i32.const 24))))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $moda (i64.load (get_local $sp)))
  (set_local $modb (i64.load (i32.sub (get_local $sp) (i32.const 8))))
  (set_local $modc (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $modd (i64.load (i32.sub (get_local $sp) (i32.const 24))))

  ;; a * 64^3 + b*64^2 + c*64 + d 
  ;; d 
  (set_local $d     (i64.add (get_local $d1) (get_local $d)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $d1))))
  ;; c
  (set_local $c     (i64.add (get_local $c) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $c) (get_local $carry))))
  (set_local $c     (i64.add (get_local $c1) (get_local $c)))
  (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $c) (get_local $c1))) (get_local $carry)))
  ;; b
  (set_local $b     (i64.add (get_local $b) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $b) (get_local $carry))))
  (set_local $b     (i64.add (get_local $b1) (get_local $b)))
  (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $b) (get_local $b1))) (get_local $carry)))
  ;; a
  (set_local $a     (i64.add (get_local $a) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $a) (get_local $carry))))
  (set_local $a     (i64.add (get_local $a1) (get_local $a)))
  (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $a) (get_local $a1))) (get_local $carry)))

  (call $MOD_320
        (get_local $carry) (get_local $a)    (get_local $b)    (get_local $c)    (get_local $d)
        (i64.const 0)      (get_local $moda) (get_local $modb) (get_local $modc) (get_local $modd) (get_local $sp))

  (get_local $sp)
)

(func $MOD_320
  ;; dividend
  (param $a i64)
  (param $b i64)
  (param $c i64)
  (param $d i64)
  (param $e i64)

  ;; divisor
  (param $a1 i64)
  (param $b1 i64)
  (param $c1 i64)
  (param $d1 i64)
  (param $e1 i64)

  ;; stack pointer
  (param $sp i32)

  ;; quotient
  (local $aq i64)
  (local $bq i64)
  (local $cq i64)
  (local $dq i64)
  (local $eq i64)

  ;; mask
  (local $maska i64)
  (local $maskb i64)
  (local $maskc i64)
  (local $maskd i64)
  (local $maske i64)

  (local $carry i32)
  (local $temp i64)

  (set_local $maske (i64.const 1))
  (block $main
    ;; check div by 0
    (if (call $isZero_320 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $e1)) 
      (then
        (set_local $a (i64.const 0))
        (set_local $b (i64.const 0))
        (set_local $c (i64.const 0))
        (set_local $d (i64.const 0))
        (set_local $e (i64.const 0))
        (br $main)
      )
    )

    ;; align bits
    (loop $done $loop
      ;; align bits;
      (if (i32.or (i64.eqz (i64.clz (get_local $a1))) (call $gte_320
                                                          (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $e1)
                                                          (get_local $a) (get_local $b) (get_local $c) (get_local $d) (get_local $e)))
        (br $done)
      )

      ;; divisor = divisor << 1
      (set_local $a1 (i64.add (i64.shl (get_local $a1) (i64.const 1)) (i64.shr_u (get_local $b1) (i64.const 63))))
      (set_local $b1 (i64.add (i64.shl (get_local $b1) (i64.const 1)) (i64.shr_u (get_local $c1) (i64.const 63))))
      (set_local $c1 (i64.add (i64.shl (get_local $c1) (i64.const 1)) (i64.shr_u (get_local $d1) (i64.const 63))))
      (set_local $d1 (i64.add (i64.shl (get_local $d1) (i64.const 1)) (i64.shr_u (get_local $e1) (i64.const 63))))
      (set_local $e1 (i64.shl (get_local $e1) (i64.const 1)))

      ;; mask = mask << 1
      (set_local $maska (i64.add (i64.shl (get_local $maska) (i64.const 1)) (i64.shr_u (get_local $maskb) (i64.const 63))))
      (set_local $maskb (i64.add (i64.shl (get_local $maskb) (i64.const 1)) (i64.shr_u (get_local $maskc) (i64.const 63))))
      (set_local $maskc (i64.add (i64.shl (get_local $maskc) (i64.const 1)) (i64.shr_u (get_local $maskd) (i64.const 63))))
      (set_local $maskd (i64.add (i64.shl (get_local $maskd) (i64.const 1)) (i64.shr_u (get_local $maske) (i64.const 63))))
      (set_local $maske (i64.shl (get_local $maske) (i64.const 1)))
      (br $loop)
    )

    (loop $done $loop
      ;; loop while mask != 0
      (if (call $isZero_320 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd) (get_local $maske))
        (br $done)
      )
      ;; if dividend >= divisor
      (if (call $gte_320 (get_local $a) (get_local $b) (get_local $c) (get_local $d) (get_local $e) (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $e1))
        (then
          ;; dividend = dividend - divisor
          (set_local $carry (i64.lt_u (get_local $e) (get_local $e1)))
          (set_local $e     (i64.sub  (get_local $e) (get_local $e1)))

          (set_local $temp  (i64.sub  (get_local $d) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $d)))
          (set_local $d     (i64.sub  (get_local $temp) (get_local $d1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $d) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $c) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $c)))
          (set_local $c     (i64.sub  (get_local $temp) (get_local $c1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $c) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $b) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $b)))
          (set_local $b     (i64.sub  (get_local $temp) (get_local $b1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $b) (get_local $temp)) (get_local $carry)))

          (set_local $a     (i64.sub  (i64.sub (get_local $a) (i64.extend_u/i32 (get_local $carry))) (get_local $a1)))
        )
      )
      ;; divisor = divisor >> 1
      (set_local $e1 (i64.add (i64.shr_u (get_local $e1) (i64.const 1)) (i64.shl (get_local $d1) (i64.const 63))))
      (set_local $d1 (i64.add (i64.shr_u (get_local $d1) (i64.const 1)) (i64.shl (get_local $c1) (i64.const 63))))
      (set_local $c1 (i64.add (i64.shr_u (get_local $c1) (i64.const 1)) (i64.shl (get_local $b1) (i64.const 63))))
      (set_local $b1 (i64.add (i64.shr_u (get_local $b1) (i64.const 1)) (i64.shl (get_local $a1) (i64.const 63))))
      (set_local $a1 (i64.shr_u (get_local $a1) (i64.const 1)))

      ;; mask = mask >> 1
      (set_local $maske (i64.add (i64.shr_u (get_local $maske) (i64.const 1)) (i64.shl (get_local $maskd) (i64.const 63))))
      (set_local $maskd (i64.add (i64.shr_u (get_local $maskd) (i64.const 1)) (i64.shl (get_local $maskc) (i64.const 63))))
      (set_local $maskc (i64.add (i64.shr_u (get_local $maskc) (i64.const 1)) (i64.shl (get_local $maskb) (i64.const 63))))
      (set_local $maskb (i64.add (i64.shr_u (get_local $maskb) (i64.const 1)) (i64.shl (get_local $maska) (i64.const 63))))
      (set_local $maska (i64.shr_u (get_local $maska) (i64.const 1)))
      (br $loop)
    )
  );; end of main
  ;; (call_import $print_64 (get_local $d))
  ;; (call_import $print_32 (get_local $sp))
  (i64.store (get_local $sp) (get_local $b))
  (i64.store (i32.sub (get_local $sp) (i32.const 8)) (get_local $c))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (get_local $d))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (get_local $e))
  (get_local $sp)
)

(func $isZero_320
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (result i32)
  (i64.eqz (i64.or (i64.or (i64.or (i64.or (get_local 0) (get_local 1)) (get_local 2)) (get_local 3)) (get_local 4)))
)

(func $gte_320
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)
  (param $a4 i64)

  (param $b0 i64)
  (param $b1 i64)
  (param $b2 i64)
  (param $b3 i64)
  (param $b4 i64)

  (result i32)
  ;; a0 > b0 || (a0 == b0 && (a1 > b1 || (a1 == b1 && (a2 > b2 || (a2 == b2 && a3 >= b3 ) ))))
  (i32.or  (i64.gt_u (get_local $a0) (get_local $b0)) ;; a0 > b0
  (i32.and (i64.eq   (get_local $a0) (get_local $b0))
  (i32.or  (i64.gt_u (get_local $a1) (get_local $b1)) ;; a1 > b1
  (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
  (i32.or  (i64.gt_u (get_local $a2) (get_local $b2)) ;; a2 > b2
  (i32.and (i64.eq   (get_local $a2) (get_local $b2))
  (i32.or  (i64.gt_u (get_local $a3) (get_local $b3)) ;; a2 > b2
  (i32.and (i64.eq   (get_local $a3) (get_local $b3))
           (i64.ge_u (get_local $a4) (get_local $b4))))))))))
)
