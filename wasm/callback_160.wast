(func $callback_160
  (param $result i32)

  (drop (call $bswap_m160 (get_global $sp)))
  (call $main)
)
