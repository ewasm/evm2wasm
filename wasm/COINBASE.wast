(func $COINBASE
  (param $sp i32)
  (result i32)
  (local $temp0 i64)
  (local $temp1 i64)
  (local $temp2 i64)
  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  ;; loads the caller into memory
  (call_import $getBlockCoinbase(get_local $sp))

  (set_local $temp0 (call $bswap_64 (i64.load (get_local $sp))))
  (set_local $temp1 (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 8)))))
  (set_local $temp2 (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 16)))))

  (i64.store (i32.add (get_local $sp) (i32.const 0)) (i64.shr_u  (get_local $temp2) (i64.const 32)))
  (i64.store (i32.add (get_local $sp) (i32.const 4)) (get_local $temp1))
  (i64.store (i32.add (get_local $sp) (i32.const 12)) (get_local $temp0))

  ;; zero out the last 96 bits
  (i32.store (i32.add (get_local $sp) (i32.const 20)) (i32.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

  (return (get_local $sp))
)
