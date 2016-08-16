(func $BLOCKHASH
  (param $sp i32)
  (result i32)
  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  ;; loads the caller into memory
  (call_import $blockHash (get_local $sp))
  ;; zero out the last 64 bits
  ;; (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

  (return (get_local $sp))
)
