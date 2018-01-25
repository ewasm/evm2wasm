(func $callback_256
  (param $result i32)

  (drop (call $bswap_m256 (get_global $sp)))
  (call $main)
)
