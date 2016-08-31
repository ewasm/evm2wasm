(func $SSTORE
  (param $sp i32)
  (call_import $storageStore (get_local $sp) (i32.sub (get_local $sp) (i32.const 32)))
)
