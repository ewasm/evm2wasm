;; not
(func $NOT
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
