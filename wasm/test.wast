(module
  ;; (import $print_mem "spectest" "print_mem")
  (export "a" memory)
  (memory 1 1)
  (func $div
    ;; divisor
    (param $a1 i64)
    (param $b1 i64)
    (param $c1 i64)
    (param $d1 i64)
  )


  (export "div" $div)
)
