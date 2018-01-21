(func $callback_128
  (export "2")
  (param $result i32)

  (call $bswap_m128 (get_global $sp))
  drop
  call $main
)
