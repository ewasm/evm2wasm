(func $callback_160
  (export "3") 
  (param $result i32)

  (call $bswap_m256 (get_global $sp))
  drop

  (call $main (i32.const 1))
)
