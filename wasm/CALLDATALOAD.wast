(func $CALLDATALOAD
  (param $sp i32)
  (result i32)
  (local $temp i64)
  (call_import $callDataCopy256 (get_local $sp) (i32.load(get_local $sp)))

  (return (get_local $sp))
)
