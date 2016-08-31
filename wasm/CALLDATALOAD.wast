(func $CALLDATALOAD
  (param $sp i32)
  (local $writeOffset i32)
  (local $writeOffset0 i64)
  (local $writeOffset1 i64)
  (local $writeOffset2 i64)
  (local $writeOffset3 i64)

  (set_local $writeOffset0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $writeOffset1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $writeOffset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $writeOffset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $writeOffset
             (call $check_overflow (get_local $writeOffset0)
                                   (get_local $writeOffset1)
                                   (get_local $writeOffset2)
                                   (get_local $writeOffset3)))

  (call_import $callDataCopy256 (get_local $sp) (get_local $writeOffset))
  ;; swap top stack item
  (call $swap_word (get_local $sp))
)
