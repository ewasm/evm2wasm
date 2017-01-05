;; stack:
;;  0: dataOffset
(func $CALLDATALOAD
  (local $writeOffset i32)
  (local $writeOffset0 i64)
  (local $writeOffset1 i64)
  (local $writeOffset2 i64)
  (local $writeOffset3 i64)

  (set_local $writeOffset0 (i64.load (i32.add (get_global $sp) (i32.const  0))))
  (set_local $writeOffset1 (i64.load (i32.add (get_global $sp) (i32.const  8))))
  (set_local $writeOffset2 (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $writeOffset3 (i64.load (i32.add (get_global $sp) (i32.const 24))))

  (i64.store (i32.add (get_global $sp) (i32.const  0)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const  8)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const 24)) (i64.const 0))

  (set_local $writeOffset
             (call $check_overflow (get_local $writeOffset0)
                                   (get_local $writeOffset1)
                                   (get_local $writeOffset2)
                                   (get_local $writeOffset3)))

  (call $callDataCopy256 (get_global $sp) (get_local $writeOffset))
  ;; swap top stack item
  (call $bswap_m256 (get_global $sp))
  drop
)
