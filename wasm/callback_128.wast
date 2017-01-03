(func $callback_128
  (param $result i32)

  (call $bswap_m128 (get_global $sp))
  drop
  call $main
)
