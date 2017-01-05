(func $MSIZE
  (local $sp i32)

  ;; there's no input item for us to overwrite
  (set_local $sp (i32.add (get_global $sp) (i32.const 32)))

  (i64.store (i32.add (get_local $sp) (i32.const 0)) 
             (i64.mul (get_global $wordCount) (i64.const 32)))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
)
