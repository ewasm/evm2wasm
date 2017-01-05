(func $LOG
  (param $number i32)

  (local $offset i32)
  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)

  (local $length i32)
  (local $length0 i64)
  (local $length1 i64)
  (local $length2 i64)
  (local $length3 i64)

  (set_local $offset0 (i64.load          (get_global $sp)))
  (set_local $offset1 (i64.load (i32.add (get_global $sp) (i32.const  8))))
  (set_local $offset2 (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $offset3 (i64.load (i32.add (get_global $sp) (i32.const 24))))

  (set_local $length0 (i64.load (i32.sub (get_global $sp) (i32.const 32))))
  (set_local $length1 (i64.load (i32.sub (get_global $sp) (i32.const 24))))
  (set_local $length2 (i64.load (i32.sub (get_global $sp) (i32.const 16))))
  (set_local $length3 (i64.load (i32.sub (get_global $sp) (i32.const  8))))

  (set_local $offset 
             (call $check_overflow (get_local $offset0)
                                   (get_local $offset1)
                                   (get_local $offset2)
                                   (get_local $offset3)))

  (set_local $length
             (call $check_overflow (get_local $length0)
                                   (get_local $length1)
                                   (get_local $length2)
                                   (get_local $length3)))

  (call $memusegas (get_local $offset) (get_local $length))

  (call $log 
             (get_local $offset)
             (get_local $length)
             (get_local $number)
             (i32.sub (get_global $sp) (i32.const  64))
             (i32.sub (get_global $sp) (i32.const  96))
             (i32.sub (get_global $sp) (i32.const 128))
             (i32.sub (get_global $sp) (i32.const 160)))
)
