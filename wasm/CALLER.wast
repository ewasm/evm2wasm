(func $CALLER
  (param $sp i32)
  (result i32)
  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  ;; loads the caller into memory
  (call_import $getCaller (get_local $sp))
  ;; zero out the last 96 bits
  (i32.store (i32.add (get_local $sp) (i32.const 20)) (i32.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

  (return (get_local $sp))
)
