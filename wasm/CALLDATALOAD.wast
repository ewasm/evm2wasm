(func $CALLDATALOAD
  (param $sp i32)
  (result i32)
  (local $temp i64)
  (call_import $callDataCopy (get_local $sp) (i32.load(get_local $sp)) (i32.const 32))

  (set_local $temp (call $bswap_64 (i64.load (get_local $sp))))
  (i64.store (get_local $sp) (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 24)))))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $temp))

  (set_local $temp (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 8)))))
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 16)))))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $temp))

  (return (get_local $sp))
)
