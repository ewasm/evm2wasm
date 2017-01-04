(func $callback_160
  (param $result i32)

  (call $bswap_m160 (get_global $sp))
  drop
  call $main
)
