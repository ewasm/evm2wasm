(func $MSIZE
  (param $sp i32)
  (result i32)

  (local $wordcount i32)

  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  (set_local $wordcount (i32.const 32768))

  (i64.store (i32.add (get_local $sp) (i32.const 0)) (i64.mul (i64.extend_u/i32 (i32.load (get_local $wordcount))) (i64.const 32)))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

  (return (get_local $sp))
)
