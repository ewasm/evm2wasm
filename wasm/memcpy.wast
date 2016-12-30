;;
;; memcpy from ewasm-libc/ewasm-cleanup
;;
(func $memcpy
  (param $dst i32)
  (param $src i32)
  (param $length i32)
  (result i32)

  (local $i i32)

  (set_local $i (i32.const 0))

  (block $done
    (loop $loop
      (if (i32.ge_u (get_local $i) (get_local $length))
        (br $done)
      )

      (i32.store8 (i32.add (get_local $dst) (get_local $i)) (i32.load8_u (i32.add (get_local $src) (get_local $i))))

      (set_local $i (i32.add (get_local $i) (i32.const 1)))
      (br $loop)
    )
  )

  (return (get_local $dst))
)
