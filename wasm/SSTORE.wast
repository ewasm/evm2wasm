;; signed less than
(func $SSTORE
  (param $sp i32)
  (result i32)

  (call_import $storageStore (get_local $sp) (i32.sub (get_local $sp) (i32.const 32)))
  ;; pop two items off the stack
  (i32.sub (get_local $sp) (i32.const 64)))
