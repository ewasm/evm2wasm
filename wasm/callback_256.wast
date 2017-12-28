(func $callback_256
  (export "1")
  (param $result i32)

  (call $bswap_m256 (get_global $sp))
  drop
  call $main
)
