(func $COINBASE
  (param $sp i32)
  (result i32)
  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))

  ;; loads the caller into memory
  (call_import $getBlockCoinbase(get_local $sp))
  (return (get_local $sp))
)
