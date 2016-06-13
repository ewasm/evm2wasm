;; greater than
(func $GT
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
