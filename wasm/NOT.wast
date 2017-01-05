(func $NOT
  ;; FIXME: consider using 0xffffffffffffffff instead of -1?
  (i64.store (i32.add (get_global $sp) (i32.const 24)) (i64.xor (i64.load (i32.add (get_global $sp) (i32.const 24))) (i64.const -1)))
  (i64.store (i32.add (get_global $sp) (i32.const 16)) (i64.xor (i64.load (i32.add (get_global $sp) (i32.const 16))) (i64.const -1)))
  (i64.store (i32.add (get_global $sp) (i32.const  8)) (i64.xor (i64.load (i32.add (get_global $sp) (i32.const  8))) (i64.const -1)))
  (i64.store (i32.add (get_global $sp) (i32.const  0)) (i64.xor (i64.load (i32.add (get_global $sp) (i32.const  0))) (i64.const -1)))
)
