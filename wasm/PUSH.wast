(func $PUSH
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)
  (local $sp i32)

  ;; increament stack pointer
  (set_local $sp (i32.add (get_global $sp) (i32.const 32)))
  (i64.store (get_local $sp) (get_local $a3))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (get_local $a2))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $a1))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $a0))
)
