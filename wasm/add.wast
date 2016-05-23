(module
  (memory 1 1)
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

  (export "add256" $add)
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
