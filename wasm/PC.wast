(func $PC
  (param $pc i32)
  (local $sp i32)

  ;; add one to the stack
  (set_local $sp (i32.add (get_global $sp) (i32.const 32)))
  (i64.store (get_local $sp) (i64.extend_u/i32 (get_local $pc)))
  ;; zero out rest of stack
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
)
