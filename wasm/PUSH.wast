;; PUSH
(func $PUSH
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)

  (param $sp i32)
  (result i32)

  (set_local $sp (i32.add (get_local $sp) (i32.const 24)))
  ;; increament stack pointer
  (set_local $sp (i32.add (get_local $sp) (i32.const 8)))
  (i64.store (get_local $sp) (get_local $a3))
  (set_local $sp (i32.add (get_local $sp) (i32.const 8)))
  (i64.store (get_local $sp) (get_local $a2))
  (set_local $sp (i32.add (get_local $sp) (i32.const 8)))
  (i64.store (get_local $sp) (get_local $a1))
  (set_local $sp (i32.add (get_local $sp) (i32.const 8)))
  (i64.store (get_local $sp) (get_local $a0))
  (set_local $sp (i32.sub (get_local $sp) (i32.const 24)))

  (return (get_local $sp))
)
