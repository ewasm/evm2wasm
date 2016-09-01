(func $CODECOPY
  (param $sp i32)
  (local $memstart i32)

  (local $writeOffset i32)
  (local $writeOffset0 i64)
  (local $writeOffset1 i64)
  (local $writeOffset2 i64)
  (local $writeOffset3 i64)

  (local $dataOffset i32)
  (local $dataOffset0 i64)
  (local $dataOffset1 i64)
  (local $dataOffset2 i64)
  (local $dataOffset3 i64)

  (local $length i32)
  (local $length0 i64)
  (local $length1 i64)
  (local $length2 i64)
  (local $length3 i64)

  (set_local $memstart (i32.const 33832))

  (set_local $length0 (i64.load (i32.sub (get_local $sp) (i32.const 64))))
  (set_local $length1 (i64.load (i32.sub (get_local $sp) (i32.const 56))))
  (set_local $length2 (i64.load (i32.sub (get_local $sp) (i32.const 48))))
  (set_local $length3 (i64.load (i32.sub (get_local $sp) (i32.const 40))))

  (set_local $dataOffset0 (i64.load (i32.sub (get_local $sp) (i32.const 32))))
  (set_local $dataOffset1 (i64.load (i32.sub (get_local $sp) (i32.const 24))))
  (set_local $dataOffset2 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $dataOffset3 (i64.load (i32.sub (get_local $sp) (i32.const  8))))

  (set_local $writeOffset0 (i64.load (i32.add (get_local $sp) (i32.const  0))))
  (set_local $writeOffset1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $writeOffset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $writeOffset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $length 
             (call $check_overflow (get_local $length0)
                                   (get_local $length1)
                                   (get_local $length2)
                                   (get_local $length3)))
  (set_local $writeOffset
             (call $check_overflow (get_local $writeOffset0)
                                   (get_local $writeOffset1)
                                   (get_local $writeOffset2)
                                   (get_local $writeOffset3)))
  (set_local $dataOffset 
             (call $check_overflow (get_local $dataOffset0)
                                   (get_local $dataOffset1)
                                   (get_local $dataOffset2)
                                   (get_local $dataOffset3)))

 (call $memUseGas (get_local $writeOffset) (get_local $length))
 (call $zero_mem (get_local $writeOffset) (get_local $length))

 (call_import $codeCopy 
              (i32.add (get_local $writeOffset) (get_local $memstart))
              (get_local $dataOffset)
              (get_local $length))

)
