(func $callback_256
  (export "4") 
  (param $result i32)

  (call $bswap_m256 (get_global $sp))
  drop
  i32.const 1
  call $main
)
