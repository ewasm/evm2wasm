(func $DIV
  (local $sp i32)
  ;; dividend
  (local $a i64)
  (local $b i64)
  (local $c i64)
  (local $d i64)

  ;; divisor
  (local $a1 i64)
  (local $b1 i64)
  (local $c1 i64)
  (local $d1 i64)

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
  (local $carry i32)
  (local $temp  i64)
  (local $temp2  i64)

  (set_local $sp (get_global $sp))
  (set_local $maskd (i64.const 1))

  ;; load args from the stack
  (set_local $a (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $b (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $c (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $d (i64.load (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $b1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $c1 (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $d1 (i64.load (get_local $sp)))

  (block $main
    ;; check div by 0
    (if (call $iszero_256 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
      (br $main)
    )

    ;; align bits
    (block $done
      (loop $loop
        ;; align bits;
        (if 
          ;; check to make sure we are not overflowing
          (i32.or (i64.eqz (i64.clz (get_local $a1)))
          ;;  divisor < dividend
          (call $gte_256 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $a) (get_local $b) (get_local $c) (get_local $d)))
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
    )


    (block $done
      (loop $loop
        ;; loop while mask != 0
        (if (call $iszero_256 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd))
          (br $done)
        )
        ;; if dividend >= divisor
        (if (call $gte_256 (get_local $a) (get_local $b) (get_local $c) (get_local $d) (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
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
            (set_local $dq   (i64.add (get_local $maskd) (get_local $dq)))
            (set_local $temp (i64.extend_u/i32 (i64.lt_u (get_local $dq) (get_local $maskd))))
            (set_local $cq   (i64.add (get_local $cq) (get_local $temp)))
            (set_local $temp (i64.extend_u/i32 (i64.lt_u (get_local $cq) (get_local $temp))))
            (set_local $cq   (i64.add (get_local $maskc) (get_local $cq)))
            (set_local $temp (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $cq) (get_local $maskc))) (get_local $temp)))
            (set_local $bq   (i64.add (get_local $bq) (get_local $temp)))
            (set_local $temp (i64.extend_u/i32 (i64.lt_u (get_local $bq) (get_local $temp))))
            (set_local $bq   (i64.add (get_local $maskb) (get_local $bq)))
            (set_local $aq   (i64.add (get_local $maska) (i64.add (get_local $aq) (i64.or (i64.extend_u/i32 (i64.lt_u (get_local $bq) (get_local $maskb))) (get_local $temp)))))
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
    )
  );; end of main

  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $aq))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $bq))
  (i64.store (i32.add (get_local $sp) (i32.const 8))  (get_local $cq))
  (i64.store (get_local $sp) (get_local $dq))
)
