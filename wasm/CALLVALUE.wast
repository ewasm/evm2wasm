(func $CALLVALUE
  (param $sp i32)
  (result i32)

  ;;add one to the stack
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))
  (call_import $getCallValue (get_local $sp))
   ;; zero out the rest of the stack
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 18)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 10)) (i64.const 0))
  (get_local $sp)
)
