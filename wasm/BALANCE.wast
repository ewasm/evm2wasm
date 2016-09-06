(import $getBalance "ethereum" "getBalance" (param i32 i32))
(func $BALANCE
  (param $sp i32)

  (call_import $getBalance (get_local $sp) (get_local $sp))
   ;; zero out the rest of the stack
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 18)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 10)) (i64.const 0))
)
