(func $ADDRESS
  (param $sp i32)
  (result i32)

  (local $scratch i32)

  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  (set_local $scratch (i32.const 32776))

  ;; clear the 3rd 64bit chunk so we don't need to mask it later
  (i64.store (i32.add (get_local $scratch) (i32.const 16)) (i64.const 0))

  ;; loads the caller into memory
  (call_import $address (get_local $scratch))

  (i64.store (i32.add (get_local $sp) (i32.const 0)) (i64.load (i32.add (get_local $scratch) (i32.const 0))))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.load (i32.add (get_local $scratch) (i32.const 8))))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.load (i32.add (get_local $scratch) (i32.const 16))))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

  (return (get_local $sp))
)
