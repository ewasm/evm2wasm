(module
  (memory 1 1)
  (func $add_test
    (param $a i64)
    (param $b i64)
    (param $c i64)
    (param $d i64)

    (param $a1 i64)
    (param $b1 i64)
    (param $c1 i64)
    (param $d1 i64)

    (param $memLoc i32)
    (result i64)

    (i64.store (i32.const 0) (get_local $d1))
    (i64.store (i32.const 8) (get_local $c1))
    (i64.store (i32.const 16) (get_local $b1))
    (i64.store (i32.const 24) (get_local $a1))

    (i64.store (i32.const 32) (get_local $d))
    (i64.store (i32.const 40) (get_local $c))
    (i64.store (i32.const 48) (get_local $b))
    (i64.store (i32.const 56) (get_local $a))

    (call $ADD (i32.const 56))
    (i64.load  (get_local $memLoc))
  )

  (func $ADD
    (param $sp i32)

    (local $a i64)
    (local $c i64)
    (local $d i64)

    (local $carry i64)

    (result i32)

    ;; d c b a
    ;; pop the stack 
    (set_local $a (i64.load (get_local $sp)))
    (set_local $c (i64.load (i32.sub (get_local $sp) (i32.const 16))))
    (set_local $d (i64.load (i32.sub (get_local $sp) (i32.const 24))))
    ;; decement the stack pointer
    (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

    ;; a * 64^3 + b*64^2 + c*64 + d 
    ;; d 
    (set_local $carry (i64.add (get_local $d) (i64.load (i32.sub (get_local $sp) (i32.const 24)))))
    ;; save d  to mem
    (i64.store (i32.sub (get_local $sp) (i32.const 24)) (get_local $carry))
    ;; check  for overflow
    (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $carry) (get_local $d))))

    ;; c use $d as reg
    (set_local $d     (i64.add (i64.load (i32.sub (get_local $sp) (i32.const 16))) (get_local $carry)))
    (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $carry))))
    (set_local $d     (i64.add (get_local $c) (get_local $d)))
    ;; store the result
    (i64.store (i32.sub (get_local $sp) (i32.const 16)) (get_local $d))
    ;; check overflow
    (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $d) (get_local $c))) (get_local $carry)))

    ;; b
    ;; add carry
    (set_local $d     (i64.add (i64.load (i32.sub (get_local $sp) (i32.const 8))) (get_local $carry)))
    (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $carry))))

    ;; use reg c
    (set_local $c (i64.load (i32.add (get_local $sp) (i32.const 24))))
    (set_local $d (i64.add (get_local $c) (get_local $d)))
    (i64.store (i32.sub (get_local $sp) (i32.const 8)) (get_local $d))
    ;; a
    (i64.store (get_local $sp) 
               (i64.add        ;; add a 
                 (get_local $a)
                 (i64.add
                   (i64.load (get_local $sp))  ;; load the operand
                   (i64.or  ;; carry 
                     (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $c))) 
                     (get_local $carry)))))

    ;;  save results
    (return (get_local $sp))
  )

  (export "add256" $add_test)
)

;; test adding max intergers
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 0)) (i64.const -2))
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 8)) (i64.const -1))
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 16)) (i64.const -1))
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i32.const 24)) (i64.const -1))

;; test adding 0 and the max interger
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 0)) (i64.const -1))
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 8)) (i64.const -1))
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 16)) (i64.const -1))
(assert_return (invoke "add256" (i64.const -1) (i64.const -1) (i64.const -1) (i64.const -1) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 0) (i32.const 24)) (i64.const -1))

;; 2 + 2
(assert_return (invoke "add256" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 0)) (i64.const 4))
(assert_return (invoke "add256" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 8)) (i64.const 0))
(assert_return (invoke "add256" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 16)) (i64.const 0))
(assert_return (invoke "add256" (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i64.const 0) (i64.const 0) (i64.const 0) (i64.const 2) (i32.const 24)) (i64.const 0))
