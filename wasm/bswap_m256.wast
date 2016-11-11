(func $bswap_m256
  (param $sp i32)
  (result i32)
  (local $temp i64)

  (set_local $temp (call $bswap_i64 (i64.load (get_local $sp))))
  (i64.store (get_local $sp) (call $bswap_i64 (i64.load (i32.add (get_local $sp) (i32.const 24)))))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $temp))

  (set_local $temp (call $bswap_i64 (i64.load (i32.add (get_local $sp) (i32.const 8)))))
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (call $bswap_i64 (i64.load (i32.add (get_local $sp) (i32.const 16)))))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $temp))
  (get_local $sp)
)
