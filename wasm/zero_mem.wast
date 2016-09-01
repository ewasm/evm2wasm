(func $zero_mem
  (param $offset i32)
  (param $length i32)

  (set_local $length (i32.add (get_local $offset) (get_local $length)))
  
  (loop $done $loop
    (if (i32.eq (get_local $offset) (get_local $length))
      (then (return))
    )
    (i32.store8 (get_local $offset) (i32.const 0)) 
    (set_local $offset (i32.add (get_local $offset) (i32.const 1)))
    (br $loop)
  )
)
