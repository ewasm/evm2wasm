(module
  (memory 1 1)
  ;; Add 0x01
  (func $add
    (param $a i64)
    (param $b i64)
    (param $c i64)
    (param $d i64)

    (param $a1 i64)
    (param $b1 i64)
    (param $c1 i64)
    (param $d1 i64)

    (param $memIndex i32)
    (result i64)
    (local $carry i64)
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
    ;; a
    (set_local $a     (i64.add (get_local $a1) (i64.add (get_local $a) (i64.or (i64.extend_u/i32 (i64.lt_u (get_local $b) (get_local $b1))) (get_local $carry)))))

    ;; add section done
    (i64.store (i32.const 0) (get_local $d))
    (i64.store (i32.const 8) (get_local $c))
    (i64.store (i32.const 16) (get_local $b))
    (i64.store (i32.const 24) (get_local $a))
    (i64.load  (get_local $memIndex))
  )
  ;; Multiplication 0x02 
  (func $mul
    ;; a = a * b
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $memIndex i32)

    (local $c0 i64)
    (local $c1 i64)
    (local $c2 i64)
    (local $c3 i64)

    (local $d0 i64)
    (local $d1 i64)
    (local $d2 i64)
    (local $d3 i64)

    (local $e0 i64)
    (local $e1 i64)
    (local $e2 i64)
    (local $e3 i64)

    (local $f0 i64)
    (local $f1 i64)
    (local $f2 i64)

    (result i64)

    ;; split the ops
    (set_local $c0 (i64.and (get_local $a0) (i64.const 4294967295)))
    (set_local $a0 (i64.shr_u (get_local $a0) (i64.const 32))) 

    (set_local $c1 (i64.and (get_local $a1) (i64.const 4294967295)))
    (set_local $a1 (i64.shr_u (get_local $a1) (i64.const 32))) 

    (set_local $c2 (i64.and (get_local $a2) (i64.const 4294967295)))
    (set_local $a2 (i64.shr_u (get_local $a2) (i64.const 32)))

    (set_local $c3 (i64.and (get_local $a3) (i64.const 4294967295)))
    (set_local $a3 (i64.shr_u (get_local $a3) (i64.const 32)))

    (set_local $d0 (i64.and (get_local $b0) (i64.const 4294967295)))
    (set_local $b0 (i64.shr_u (get_local $b0) (i64.const 32))) 

    (set_local $d1 (i64.and (get_local $b1) (i64.const 4294967295)))
    (set_local $b1 (i64.shr_u (get_local $b1) (i64.const 32))) 

    (set_local $d2 (i64.and (get_local $b2) (i64.const 4294967295)))
    (set_local $b2 (i64.shr_u (get_local $b2) (i64.const 32)))

    (set_local $d3 (i64.and (get_local $b3) (i64.const 4294967295)))
    (set_local $b3 (i64.shr_u (get_local $b3) (i64.const 32)))
    ;; first row multiplication 
    ;; p * h
    (set_local $f2 (i64.mul (get_local $d3) (get_local $c3)))
    ;; p * g + carry
    (set_local $f1 (i64.add (i64.mul (get_local $d3) (get_local $a3)) (i64.shr_u (get_local $f2) (i64.const 32))))
    ;; p * f + carry
    (set_local $f0 (i64.add (i64.mul (get_local $d3) (get_local $c2)) (i64.shr_u (get_local $f1) (i64.const 32))))
    ;; p * e + carry
    (set_local $e3 (i64.add (i64.mul (get_local $d3) (get_local $a2)) (i64.shr_u (get_local $f0) (i64.const 32))))
    ;; p * d + carry
    (set_local $e2 (i64.add (i64.mul (get_local $d3) (get_local $c1)) (i64.shr_u (get_local $e3) (i64.const 32))))
    ;; p * c + carry
    (set_local $e1  (i64.add (i64.mul (get_local $d3) (get_local $a1)) (i64.shr_u (get_local $e2) (i64.const 32))))
    ;; p * b + carry
    (set_local $e0  (i64.add (i64.mul (get_local $d3) (get_local $c0)) (i64.shr_u (get_local $e1) (i64.const 32))))
    ;; p * a + carry
    (set_local $a0  (i64.add (i64.mul (get_local $d3) (get_local $a0)) (i64.shr_u (get_local $e0) (i64.const 32))))
    ;; second row
    ;; o * h + $f1 (pg)
    (set_local $f1 (i64.add (i64.mul (get_local $b3) (get_local $c3)) (i64.and (get_local $f1) (i64.const 4294967295))))
    ;; o * g + $f0 (pf) + carry
    (set_local $f0 (i64.add (i64.add (i64.mul (get_local $b3) (get_local $a3)) (i64.and (get_local $f0) (i64.const 4294967295))) (i64.shr_u (get_local $f1) (i64.const 32))))
    ;; o * f + $e3 (pe) + carry
    (set_local $e3 (i64.add (i64.add (i64.mul (get_local $b3) (get_local $c2)) (i64.and (get_local $e3) (i64.const 4294967295))) (i64.shr_u (get_local $f0) (i64.const 32))))
    ;; o * e + $e2 (pd) + carry
    (set_local $e2 (i64.add (i64.add (i64.mul (get_local $b3) (get_local $a2)) (i64.and (get_local $e2) (i64.const 4294967295))) (i64.shr_u (get_local $e3) (i64.const 32))))
    ;; o * d + $e1 (pc) + carry
    (set_local $e1 (i64.add (i64.add (i64.mul (get_local $b3) (get_local $c1)) (i64.and (get_local $e1) (i64.const 4294967295))) (i64.shr_u (get_local $e2) (i64.const 32))))
    ;; o * c + $e0 (pb) + carry
    (set_local $e0 (i64.add (i64.add (i64.mul (get_local $b3) (get_local $a1)) (i64.and (get_local $e0) (i64.const 4294967295))) (i64.shr_u (get_local $e1) (i64.const 32))))
    ;; o * b + $a0 (pa) + carry
    (set_local $a0 (i64.add (i64.add (i64.mul (get_local $b3) (get_local $c0)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))))
    ;; third row - n
    ;; n * h + $f0 (og)
    (set_local $f0 (i64.add (i64.mul (get_local $d2) (get_local $c3)) (i64.and (get_local $f0) (i64.const 4294967295))))
    ;; n * g + $e3 (of) + carry
    (set_local $e3 (i64.add (i64.add (i64.mul (get_local $d2) (get_local $a3)) (i64.and (get_local $e3) (i64.const 4294967295))) (i64.shr_u (get_local $f0) (i64.const 32))))
    ;; n * f + $e2 (oe) + carry
    (set_local $e2 (i64.add (i64.add (i64.mul (get_local $d2) (get_local $c2)) (i64.and (get_local $e2) (i64.const 4294967295))) (i64.shr_u (get_local $e3) (i64.const 32))))
    ;; n * e + $e1 (od) + carry
    (set_local $e1 (i64.add (i64.add (i64.mul (get_local $d2) (get_local $a2)) (i64.and (get_local $e1) (i64.const 4294967295))) (i64.shr_u (get_local $e2) (i64.const 32))))
    ;; n * d + $e0 (oc) + carry
    (set_local $e0 (i64.add (i64.add (i64.mul (get_local $d2) (get_local $c1)) (i64.and (get_local $e0) (i64.const 4294967295))) (i64.shr_u (get_local $e1) (i64.const 32))))
    ;; n * c + $a0 (ob) + carry
    (set_local $a0 (i64.add (i64.add (i64.mul (get_local $d2) (get_local $a1)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))))

    ;; forth row 
    ;; m * h + $e3 (ng)
    (set_local $e3 (i64.add (i64.mul (get_local $b2) (get_local $c3)) (i64.and (get_local $e3) (i64.const 4294967295))))
    ;; m * g + $e2 (nf) + carry
    (set_local $e2 (i64.add (i64.add (i64.mul (get_local $b2) (get_local $a3)) (i64.and (get_local $e2) (i64.const 4294967295))) (i64.shr_u (get_local $e3) (i64.const 32))))
    ;; m * f + $e1 (oe) + carry
    (set_local $e1 (i64.add (i64.add (i64.mul (get_local $b2) (get_local $c2)) (i64.and (get_local $e1) (i64.const 4294967295))) (i64.shr_u (get_local $e2) (i64.const 32))))
    ;; m * e + $e0 (od) + carry
    (set_local $e0 (i64.add (i64.add (i64.mul (get_local $b2) (get_local $a2)) (i64.and (get_local $e0) (i64.const 4294967295))) (i64.shr_u (get_local $e1) (i64.const 32))))
    ;; m * d + $a0 (oc) + carry
    (set_local $a0 (i64.add (i64.add (i64.mul (get_local $b2) (get_local $c1)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))))

    ;; fith row
    ;; l * h + $e2 (ng)
    (set_local $e2 (i64.add (i64.mul (get_local $d1) (get_local $c3)) (i64.and (get_local $e2) (i64.const 4294967295))))
    ;; l * g + $e1 (nf) + carry
    (set_local $e1 (i64.add (i64.add (i64.mul (get_local $d1) (get_local $a3)) (i64.and (get_local $e1) (i64.const 4294967295))) (i64.shr_u (get_local $e2) (i64.const 32))))
    ;; l * f + $e0 (oe) + carry
    (set_local $e0 (i64.add (i64.add (i64.mul (get_local $d1) (get_local $c2)) (i64.and (get_local $e0) (i64.const 4294967295))) (i64.shr_u (get_local $e1) (i64.const 32))))
    ;; l * e + $a0 (od) + carry
    (set_local $a0 (i64.add (i64.add (i64.mul (get_local $d1) (get_local $a2)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))))

    ;; sixth row 
    ;; k * h + $e1 (ng)
    (set_local $e1 (i64.add (i64.mul (get_local $b1) (get_local $c3)) (i64.and (get_local $e1) (i64.const 4294967295))))
    ;; k * g + $e0 (nf) + carry
    (set_local $e0 (i64.add (i64.add (i64.mul (get_local $b1) (get_local $a3)) (i64.and (get_local $e0) (i64.const 4294967295))) (i64.shr_u (get_local $e1) (i64.const 32))))
    ;; k * f + $a0 (oe) + carry
    (set_local $a0 (i64.add (i64.add (i64.mul (get_local $b1) (get_local $c2)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))))

    ;; seventh row
    ;; j * h + $e0 (ng)
    (set_local $e0 (i64.add (i64.mul (get_local $d0) (get_local $c3)) (i64.and (get_local $e0) (i64.const 4294967295))))
    ;; j * g + $a0 (nf) + carry
    ;; (set_local $a0 (i64.add (i64.add (i64.mul (get_local $d0) (get_local $a3)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))))

    ;; eigth row
    ;; i * h + $a0 (jg)
    (set_local $a0 (i64.add (i64.mul (get_local $b0) (get_local $c3)) (i64.and (i64.add (i64.add (i64.mul (get_local $d0) (get_local $a3)) (i64.and (get_local $a0) (i64.const 4294967295))) (i64.shr_u (get_local $e0) (i64.const 32))) (i64.const 4294967295))))

    ;; combine terms
    (set_local $a0 (i64.or (i64.shl (get_local $a0) (i64.const 32)) (i64.and (get_local $e0) (i64.const 4294967295))))
    (set_local $a1 (i64.or (i64.shl (get_local $e1) (i64.const 32)) (i64.and (get_local $e2) (i64.const 4294967295))))
    (set_local $a2 (i64.or (i64.shl (get_local $e3) (i64.const 32)) (i64.and (get_local $f0) (i64.const 4294967295))))
    (set_local $a3 (i64.or (i64.shl (get_local $f1) (i64.const 32)) (i64.and (get_local $f2) (i64.const 4294967295))))
    ;; section done
    (i64.store (i32.const 0) (get_local $a0))
    (i64.store (i32.const 8) (get_local $a1))
    (i64.store (i32.const 16) (get_local $a2))
    (i64.store (i32.const 24) (get_local $a3))
    (i64.load  (get_local $memIndex))
  )
  ;; Subtraction 0x03
  (func $sub
    (param $a i64)
    (param $b i64)
    (param $c i64)
    (param $d i64)

    (param $a1 i64)
    (param $b1 i64)
    (param $c1 i64)
    (param $d1 i64)
    (param $memIndex i32)

    (local $carry i64)
    (local $temp i64)
    (result i64)

    ;; a * 64^3 + b*64^2 + c*64 + d 
    ;; d
    (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $d1))))
    (set_local $d (i64.sub (get_local $d) (get_local $d1)))
  
    ;; c
    (set_local $temp (i64.sub (get_local $c) (get_local $carry)))
    (set_local $carry (i64.extend_u/i32 (i64.gt_u (get_local $temp) (get_local $c))))
    (set_local $c (i64.sub (get_local $temp) (get_local $c1)))
    (set_local $carry (i64.or (i64.extend_u/i32 (i64.gt_u (get_local $c) (get_local $temp))) (get_local $carry)))

    ;; b
    (set_local $temp (i64.sub (get_local $b) (get_local $carry)))
    (set_local $carry (i64.extend_u/i32 (i64.gt_u (get_local $temp) (get_local $b))))
    (set_local $b (i64.sub (get_local $temp) (get_local $b1)))

    ;; a
    (set_local $a (i64.sub (i64.sub (get_local $a) (i64.or (i64.extend_u/i32 (i64.gt_u (get_local $b) (get_local $temp))) (get_local $carry))) (get_local $a1)))

    ;; add section done
    (i64.store (i32.const 0) (get_local $d))
    (i64.store (i32.const 8) (get_local $c))
    (i64.store (i32.const 16) (get_local $b))
    (i64.store (i32.const 24) (get_local $a))
    (i64.load  (get_local $memIndex))
  )
  
  ;; division 0x04
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
    (local $carry i32)
    (local $temp  i64)
    (local $temp2  i64)
    (result i64)

    (set_local $maskd (i64.const 1))

    (block $main
      ;; check div by 0
      (if (call $isZero_i32 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
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
        (if (call $isZero_i32 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd))
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
    );; end of main

    ;; add section done
    (i64.store (i32.const 0)  (get_local $aq))
    (i64.store (i32.const 8)  (get_local $bq))
    (i64.store (i32.const 16) (get_local $cq))
    (i64.store (i32.const 24) (get_local $dq))
    ;; (call_import $print_mem)
    (i64.load  (get_local $memIndex))
  )

  ;; Signed division 0x03
  (func $sdiv
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

    (local $sign  i32)
    (local $carry i32)
    (local $temp  i64)
    (result i64)

    (set_local $maskd (i64.const 1))
    ;; get the resulting sign
    (set_local $sign (i32.wrap/i64 (i64.shr_u (i64.xor (get_local $d1) (get_local $d)) (i64.const 63))))

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
      (if (call $isZero_i32 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
        (br $main)
      )

      ;; align bits
      (loop $done $loop
        ;; align bits;
        (if (i32.or (i64.eqz (i64.clz (get_local $a1))) (call $gte (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $a) (get_local $b) (get_local $c) (get_local $d)))
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
        (if (call $isZero_i32 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd))
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

    ;; convert to signed
    (if (get_local $sign)
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

  ;; Modulo 0x06
  (func $mod
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
    (local $carry i32)
    (local $temp  i64)
    (local $temp2  i64)
    (result i64)

    (set_local $maskd (i64.const 1))

    (block $main
      ;; check div by 0
      (if (call $isZero_i32 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
        (then
          (set_local $a (i64.const 0))
          (set_local $b (i64.const 0))
          (set_local $c (i64.const 0))
          (set_local $d (i64.const 0))
          (br $main)
        )
      )

      ;; align bits
      (loop $done $loop
        ;; align bits;
        (if (i32.or (i64.eqz (i64.clz (get_local $a1))) (call $gte (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $a) (get_local $b) (get_local $c) (get_local $d)))
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
        (if (call $isZero_i32 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd))
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

    ;; add section done
    (i64.store (i32.const 0)  (get_local $a))
    (i64.store (i32.const 8)  (get_local $b))
    (i64.store (i32.const 16) (get_local $c))
    (i64.store (i32.const 24) (get_local $d))
    ;; (call_import $print_mem)
    (i64.load  (get_local $memIndex))
  )
  
  ;; sign modulo 0x07
  (func $smod
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
    (local $carry i32)
    (local $temp  i64)
    (local $temp2  i64)
    (local $sign i32)
    (result i64)

    (set_local $maskd (i64.const 1))
    (set_local $sign (i32.wrap/i64 (i64.shr_u (get_local $d) (i64.const 63))))

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
    
      (i64.store (i32.const 0)  (get_local $a))
      (i64.store (i32.const 8)  (get_local $b))
      (i64.store (i32.const 16) (get_local $c))
      (i64.store (i32.const 24) (get_local $d))

      (i64.store (i32.const 0)  (get_local $a1))
      (i64.store (i32.const 8)  (get_local $b1))
      (i64.store (i32.const 16) (get_local $c1))
      (i64.store (i32.const 24) (get_local $d1))


    (block $main
      ;; check div by 0
      (if (call $isZero_i32 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1))
        (then
          (set_local $a (i64.const 0))
          (set_local $b (i64.const 0))
          (set_local $c (i64.const 0))
          (set_local $d (i64.const 0))
          (br $main)
        )
      )

      ;; align bits
      (loop $done $loop
        ;; align bits;
        (if (i32.or (i64.eqz (i64.clz (get_local $a1))) (call $gte (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $a) (get_local $b) (get_local $c) (get_local $d)))
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
        (if (call $isZero_i32 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd))
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

    ;; convert to signed
    (if (get_local $sign)
      (then
        (set_local $a (i64.xor (get_local $a) (i64.const -1)))
        (set_local $b (i64.xor (get_local $b) (i64.const -1)))
        (set_local $c (i64.xor (get_local $c) (i64.const -1)))
        (set_local $d (i64.xor (get_local $d) (i64.const -1)))

        (set_local $d (i64.add (get_local $d) (i64.const 1)))
        (set_local $c (i64.add (get_local $c) (i64.extend_u/i32 (i64.eqz (get_local $d)))))
        (set_local $b (i64.add (get_local $b) (i64.extend_u/i32 (i64.eqz (get_local $c)))))
        (set_local $a (i64.add (get_local $a) (i64.extend_u/i32 (i64.eqz (get_local $b)))))
      )
    )
    ;; add section done
    (i64.store (i32.const 0)  (get_local $a))
    (i64.store (i32.const 8)  (get_local $b))
    (i64.store (i32.const 16) (get_local $c))
    (i64.store (i32.const 24) (get_local $d))
    (i64.load  (get_local $memIndex))
  )

  ;; Addition Modulo 0x08
  (func $addmod
    (param $sp i32)
    (unreachable)
  )

  ;; Addition Modulo 0x09
  (func $mulmod
    (param $sp i32)
    (unreachable)
  )

  ;; Exponential 0x0a
  (func $exp
    ;; base
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    ;; exp
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $sp i32)

    (local $r0 i64)
    (local $r1 i64)
    (local $r2 i64)
    (local $r3 i64)

    ;; let result = new BN(1)
    (set_local $r3 (i64.const 1))

    (loop $done $loop
       ;; while (exp > 0) {
      (if (call $isZero_i32 (get_local $b0) (get_local $b1) (get_local $b2) (get_local $b3))
        (br $done) 
      )
      
      ;; if(exp.modn(2) === 1)
      ;; is odd?
      (if (i64.eqz (i64.ctz (get_local $b3)))
        ;; result = result.mul(base).mod(TWO_POW256)
        ;; r = r * a
        (then
          (call $mul (get_local $r0) (get_local $r1) (get_local $r2) (get_local $r3) (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3) (get_local $sp))
          (set_local $r0 (i64.load (get_local $sp)))
          (set_local $r1 (i64.load (i32.add (get_local $sp) (i32.const 8))))
          (set_local $r2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
          (set_local $r3 (i64.load (i32.add (get_local $sp) (i32.const 24))))
        )
      )
      ;; exp = exp.shrn(1)
      (set_local $b0 (i64.shr_u (get_local $b0) (i64.const 1)))
      (set_local $b1 (i64.shr_u (get_local $b1) (i64.const 1)))
      (set_local $b2 (i64.shr_u (get_local $b2) (i64.const 1)))
      (set_local $b3 (i64.shr_u (get_local $b3) (i64.const 1)))

      ;; base = base.mul(base).mod(TWO_POW256)
      (call $mul (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3) (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3) (get_local $sp))
      (set_local $a0 (i64.load (get_local $sp)))
      (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 8))))
      (set_local $a2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
      (set_local $a3 (i64.load (i32.add (get_local $sp) (i32.const 24))))
      (br $loop)
    ) 

    (i64.store (get_local $sp) (get_local $r0))
    (i64.store (i32.add (i32.const 8) (get_local $sp)) (get_local $r1))
    (i64.store (i32.add (i32.const 16) (get_local $sp)) (get_local $r2))
    (i64.store (i32.add (i32.const 24) (get_local $sp)) (get_local $r3))
  )

  ;; Extend length of two’s ( complement signed integer. 0x0b
  (func $signextend
    (param $sp i32)
    (unreachable)
  )

  ;; less than 0x0c
  (func $lt
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)
    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend_u/i32
        (call $lt_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )

  ;; greater than
  (func $gt
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)
    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend_u/i32
        (call $gt_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )

  ;; signed less than
  (func $slt
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)
    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend_u/i32
        (call $slt_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )

  ;; signed greater than
  (func $sgt
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $sp i32)


    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend_u/i32
        (call $sgt_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )
  (func $sgt_i32
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
 
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    ;; a0 > b0 || (a0 == b0 && (a1 > b1 || (a1 == b1 && (a2 > b2 || (a2 == b2 && a3 > b3 ) ))))
    (i32.or  (i64.gt_s (get_local $a0) (get_local $b0)) ;; a0 > b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == a1
    (i32.or  (i64.gt_u (get_local $a1) (get_local $b1)) ;; a1 > b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.gt_u (get_local $a2) (get_local $b2)) ;; a2 > b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.gt_u (get_local $a3) (get_local $b3)))))))) ;; a3 > b3
  )

  ;; equals 0x14
  (func $eq
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend_u/i32
        (call $eq_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )
  (func $eq_i32
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
 
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == a1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.eq   (get_local $a3) (get_local $b3))))) ;; a3 == b3
  )

  ;; is zero
  (func $isZero
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend_u/i32
        (call $isZero_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3))
      )
    )
  )
  (func $isZero_i32
    (param i64)
    (param i64)
    (param i64)
    (param i64)
    (result i32)
    (i64.eqz (i64.or (i64.or (i64.or (get_local 0) (get_local 1)) (get_local 2)) (get_local 3))) 
  )

  ;; and
  (func $and
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.or (get_local $a0) (get_local $b0)))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.and (get_local $a1) (get_local $b1)))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.and (get_local $a2) (get_local $b2)))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.and (get_local $a3) (get_local $b3)))
  )

  ;; or
  (func $or
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)
    (param $sp i32)

    (i64.store (get_local $sp) (i64.or (get_local $a0) (get_local $b0)))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.or (get_local $a1) (get_local $b1)))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.or (get_local $a2) (get_local $b2)))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.or (get_local $a3) (get_local $b3)))
  )


  ;; xor
  (func $xor
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.xor (get_local $a0) (get_local $b0)))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.xor (get_local $a1) (get_local $b1)))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.xor (get_local $a2) (get_local $b2)))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.xor (get_local $a3) (get_local $b3)))
  )

  ;; not
  (func $not
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.xor (get_local $a0) (i64.const -1)))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.xor (get_local $a1) (i64.const -1)))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.xor (get_local $a2) (i64.const -1)))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.xor (get_local $a3) (i64.const -1)))
  )

  ;; byte
  (func $byte
    (param $sp i32)
    (local $a3 i64)

    (set_local $a3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

    ;; if (a > 32)
    ;; a0 == 0 && a1 == 0 && a2 == 0 && a3 > 32
    (if 
      (i32.and (i64.gt_u (get_local $a3) (i64.const 32))
      (i32.and (i64.eqz  (i64.load (i32.add (get_local $sp) (i32.const 16))))
      (i32.and (i64.eqz  (i64.load (i32.add (get_local $sp) (i32.const 8))))
               (i64.eqz  (i64.load (get_local $sp))))))
      (return)
    )

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    ;; sp + 32 + a
    (i64.store (i32.add (get_local $sp) (i32.const 24))
               (i64.load8_u  (i32.add (i32.add (i32.wrap/i64 (get_local $a3)) (i32.const 32)) (get_local $sp))))
  )

  ;; Helper functions
  ;; less than; return i32
  (func $lt_i32
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
 
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    ;; a0 < b0 || (a0 == b0 && (a1 < b1 || (a1 == b1 && (a2 < b2 || (a2 == b2 && a3 < b3 ) ))))
    (i32.or  (i64.lt_u (get_local $a0) (get_local $b0)) ;; a0 < b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == b0
    (i32.or  (i64.lt_u (get_local $a1) (get_local $b1)) ;; a1 < b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.lt_u (get_local $a2) (get_local $b2)) ;; a2 < b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.lt_u (get_local $a3) (get_local $b3)))))))) ;; a3 < b3
  )

  ;; great than i32
  (func $gt_i32
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
 
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    ;; a0 > b0 || (a0 == b0 && (a1 > b1 || (a1 == b1 && (a2 > b2 || (a2 == b2 && a3 > b3 ) ))))
    (i32.or  (i64.gt_u (get_local $a0) (get_local $b0)) ;; a0 > b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == a1
    (i32.or  (i64.gt_u (get_local $a1) (get_local $b1)) ;; a1 > b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.gt_u (get_local $a2) (get_local $b2)) ;; a2 > b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.gt_u (get_local $a3) (get_local $b3)))))))) ;; a3 > b3
  )
  ;; less than
  (func $slt_i32
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
 
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    ;; a0 < b0 || (a0 == b0 && (a1 < b1 || (a1 == b1 && (a2 < b2 || (a2 == b2 && a3 < b3 ) ))))
    (i32.or  (i64.lt_s (get_local $a0) (get_local $b0)) ;; a0 < b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == b0
    (i32.or  (i64.lt_u (get_local $a1) (get_local $b1)) ;; a1 < b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.lt_u (get_local $a2) (get_local $b2)) ;; a2 < b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.lt_u (get_local $a3) (get_local $b3)))))))) ;; a3 < b3
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
)
