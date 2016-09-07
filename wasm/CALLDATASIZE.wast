(import $getCallDataSize "ethereum" "getCallDataSize" (result i32))
(func $CALLDATASIZE
  (param $sp i32)

  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  (i64.store          (get_local $sp)                 (i64.extend_u/i32 (call_import $getCallDataSize)))
  (i64.store (i32.add (get_local $sp) (i32.const 8))  (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
)
