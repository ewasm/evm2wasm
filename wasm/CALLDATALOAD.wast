(func $CALLDATALOAD
  (param $sp i32)
  (result i32)
  (call_import $callDataCopy (i32.load(get_local $sp)) (get_local $sp) (i32.const 32))
  (return (get_local $sp))
)
