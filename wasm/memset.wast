(func $memset
  (param $ptr i32)
  (param $value i32)
  (param $length i32)
  (result i32)
  (local $i i32)

  (set_local $i (i32.const 0))

  (block $done
    (loop $loop
      (if (i32.ge_u (get_local $i) (get_local $length))
        (br $done)
      )

      (i32.store8 (i32.add (get_local $ptr) (get_local $i)) (get_local $value))

      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $loop)
    )
  )
  (get_local $ptr)
)
