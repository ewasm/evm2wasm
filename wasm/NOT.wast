;; NOT(sp[-1])
(func $NOT
  (param $sp i32)
  (result i32)

  ;; FIXME: consider using 0xffffffffffffffff instead of -1?
  (i64.store (i32.sub (get_local $sp) (i32.const 0)) (i64.xor (i64.load (i32.sub (get_local $sp) (i32.const 0))) (i64.const -1)))
  (i64.store (i32.sub (get_local $sp) (i32.const 8)) (i64.xor (i64.load (i32.sub (get_local $sp) (i32.const 8))) (i64.const -1)))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (i64.xor (i64.load (i32.sub (get_local $sp) (i32.const 16))) (i64.const -1)))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (i64.xor (i64.load (i32.sub (get_local $sp) (i32.const 24))) (i64.const -1)))

  (return (get_local $sp))
)
