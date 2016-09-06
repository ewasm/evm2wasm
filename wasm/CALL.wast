;; gasLimit, toAddress, value, inOffset, inLength, outOffset, outLength,
(func $CALL
  (param $sp i32)      

  (local $memstart i32)

  (local $dataOffset i32)
  (local $dataOffset0 i64)
  (local $dataOffset1 i64)
  (local $dataOffset2 i64)
  (local $dataOffset3 i64)

  (local $dataLength  i32)
  (local $dataLength0 i64)
  (local $dataLength1 i64)
  (local $dataLength2 i64)
  (local $dataLength3 i64)

  (local $writeOffset i32)
  (local $writeOffset0 i64)
  (local $writeOffset1 i64)
  (local $writeOffset2 i64)
  (local $writeOffset3 i64)

  (local $writeLength  i32)
  (local $writeLength0 i64)
  (local $writeLength1 i64)
  (local $writeLength2 i64)
  (local $writeLength3 i64)

  (set_local $memstart (i32.const 33832))

  ;; remove 3 items from the stack
  (set_local $sp (i32.sub (get_local $sp) (i32.const 96)))

  (set_local $dataOffset0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $dataOffset1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $dataOffset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $dataOffset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $dataLength0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $dataLength1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $dataLength2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $dataLength3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $writeOffset0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $writeOffset1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $writeOffset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $writeOffset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $writeLength0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $writeLength1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $writeLength2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $writeLength3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $dataLength
             (call $check_overflow (get_local $dataLength0)
                                   (get_local $dataLength1)
                                   (get_local $dataLength2)
                                   (get_local $dataLength3)))
  (set_local $dataOffset
             (call $check_overflow (get_local $dataOffset0)
                                   (get_local $dataOffset1)
                                   (get_local $dataOffset2)
                                   (get_local $dataOffset3)))
  (set_local $writeLength
             (call $check_overflow (get_local $writeLength0)
                                   (get_local $writeLength1)
                                   (get_local $writeLength2)
                                   (get_local $writeLength3)))
  (set_local $writeOffset
             (call $check_overflow (get_local $writeOffset0)
                                   (get_local $writeOffset1)
                                   (get_local $writeOffset2)
                                   (get_local $writeOffset3)))

 (call $memUseGas (get_local $dataOffset) (get_local $dataLength))
 (call $memUseGas (get_local $writeOffset) (get_local $writeLength))

  ;; zero out rest of stack
  (i64.store (i32.add (get_local $sp) (i32.const 0)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
)
