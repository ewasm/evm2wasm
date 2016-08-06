;; PUSH
(func $PUSH
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)

  (param $sp i32)
  (result i32)

  ;; increament stack pointer
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))
  (i64.store (get_local $sp) (get_local $a3))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (get_local $a2))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $a1))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $a0))

  (return (get_local $sp))
)
