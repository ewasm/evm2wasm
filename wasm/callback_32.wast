(func $callback_32
  (param $result i32)

  (i64.store (get_global $sp) (i64.extend_u/i32 (get_local $result)))
  ;; zero out mem
  (i64.store (i32.add (get_global $sp) (i32.const 24)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const 8)) (i64.const 0))

  call $main
)

