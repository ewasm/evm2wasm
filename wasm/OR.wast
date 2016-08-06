;; OR(sp[-1], sp[-2])
(func $OR
  (param $sp i32)
  (result i32)

  (i64.store (i32.sub (get_local $sp) (i32.const 32)) (i64.or (i64.load (i32.sub (get_local $sp) (i32.const 32))) (i64.load (i32.sub (get_local $sp) (i32.const 0)))))
  (i64.store (i32.sub (get_local $sp) (i32.const 40)) (i64.or (i64.load (i32.sub (get_local $sp) (i32.const 40))) (i64.load (i32.sub (get_local $sp) (i32.const 8)))))
  (i64.store (i32.sub (get_local $sp) (i32.const 48)) (i64.or (i64.load (i32.sub (get_local $sp) (i32.const 48))) (i64.load (i32.sub (get_local $sp) (i32.const 16)))))
  (i64.store (i32.sub (get_local $sp) (i32.const 56)) (i64.or (i64.load (i32.sub (get_local $sp) (i32.const 56))) (i64.load (i32.sub (get_local $sp) (i32.const 24)))))

  (return (i32.sub (get_local $sp) (i32.const 32)))
)
