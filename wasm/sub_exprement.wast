;; trying to find out how wasm nummbers overflow on addition
(module
  (import $print_i64 "spectest" "print" (param i64))
  (start $start)
  (func $sub (param $a i64) (param $b i64) (result i64)
    (i64.sub (get_local $a) (get_local $b))
  )
  (func $start
    (call_import $print_i64
      (call $sub (i64.const 9223372036854775806) (i64.const 1))
    )
  )
  (export "add" $sub)
)
;; (invoke "add" (f64.const 9223372036854775807) (f64.const 9223372036854775807))
