(func $PC
  (param $pc i64)
  (param $sp i32)
  (result i32)

  ;; add one to the stack
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))
  (i64.store (get_local $sp) (get_local $pc))  
  ;; zero out rest of stack

  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
  (get_local $sp)
)
