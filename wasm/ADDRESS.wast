(import $getAddress "ethereum" "getAddress" (param i32))
(func $ADDRESS
  (param $sp i32)
  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  ;; loads the caller into memory
  (call_import $getAddress (get_local $sp))

  ;; zero out the rest of the stack
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
  (i32.store (i32.add (get_local $sp) (i32.const 20)) (i32.const 0))
)
