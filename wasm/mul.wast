(module
  (import $print_i64 "spectest" "print" (param i64))
  (export "a" memory)
  (memory 1 1)
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
  (export "mul" $mul)
)

;; 2^255 * 0
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 0)) (i64.const 0))
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 8)) (i64.const 0))
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 16)) (i64.const 0))
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 24)) (i64.const 0))

;; 2^255 * 2^255
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 0)) (i64.const 0))
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 8)) (i64.const 0))
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 16)) (i64.const 0))
(assert_return (invoke "mul" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 24)) (i64.const 1))

(assert_return (invoke "mul" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 0)) (i64.const 0))
(assert_return (invoke "mul" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 0)) (i64.const 0))
(assert_return (invoke "mul" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 0)) (i64.const 0))
(assert_return (invoke "mul" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 24)) (i64.const 4))

;; (2 ^32) * (2^32)
(assert_return (invoke "mul" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 4294967295) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 4294967295) (i32.const 24)) (i64.const -8589934591))
