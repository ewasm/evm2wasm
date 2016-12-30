(func $callback_32
  (export "1") 
  (param $result i32)

  (local $sp i32)
  (local $sp_loc i32)

  (set_local $sp_loc (i32.const 32788))
  (set_local $sp (i32.load (get_local $sp_loc)))

  (i64.store (get_local $sp) (i64.extend_u/i32 (get_local $result)))
  ;; zero out mem
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))

  (call $main (i32.const 1))
)

