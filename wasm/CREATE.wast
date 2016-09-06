(func $CREATE
  (param $sp i32)      

  (local $memstart i32)
  (local $offset   i32)
  (local $length   i32)

  (local $offset0  i64)
  (local $offset1  i64)
  (local $offset2  i64)
  (local $offset3  i64)
  (local $length0  i64)
  (local $length1  i64)
  (local $length2  i64)
  (local $length3  i64)

  (set_local $memstart (i32.const 33832))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $offset0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $offset1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $offset2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $offset3 (i64.load          (get_local $sp)))

  (set_local $length0 (i64.load (i32.sub (get_local $sp) (i32.const  8))))
  (set_local $length1 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $length2 (i64.load (i32.sub (get_local $sp) (i32.const 24))))
  (set_local $length3 (i64.load (i32.sub (get_local $sp) (i32.const 32))))

  (set_local $offset
             (call $check_overflow (get_local $offset3)
                                   (get_local $offset2)
                                   (get_local $offset1)
                                   (get_local $offset0)))
  (set_local $length 
             (call $check_overflow (get_local $length3)
                                   (get_local $length2)
                                   (get_local $length1)
                                   (get_local $length0)))

  (call $memUseGas (get_local $offset) (get_local $length))
  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))
  ;; zero out rest of stack
  (i64.store (i32.add (get_local $sp) (i32.const 0)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

)
