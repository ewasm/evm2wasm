(import $getGasLeft "ethereum" "getGasLeft" (result i64))
(func $GAS
  (param $sp i32)

  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))
   ;; zero out the rest of the stack
  (i64.store (get_local $sp) (call_import $getGasLeft))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 8))  (i64.const 0))
)
