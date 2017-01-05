(func $SIGNEXTEND
  (local $sp i32)

  (local $a0 i64)
  (local $a1 i64)
  (local $a2 i64)
  (local $a3 i64)

  (local $b0 i64)
  (local $b1 i64)
  (local $b2 i64)
  (local $b3 i64)
  (local $sign i64)
  (local $t i32)
  (local $end i32)

  (set_local $a0 (i64.load (i32.add (get_global $sp) (i32.const 24))))
  (set_local $a1 (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $a2 (i64.load (i32.add (get_global $sp) (i32.const  8))))
  (set_local $a3 (i64.load          (get_global $sp)))

  (set_local $end (get_global $sp))
  (set_local $sp (i32.sub (get_global $sp) (i32.const 32)))

  (if (i32.and 
        (i32.and 
          (i32.and 
            (i64.lt_u (get_local $a3) (i64.const 32))
            (i64.eqz (get_local $a2))) 
          (i64.eqz (get_local $a1)))
        (i64.eqz (get_local $a0)))
    (then
      (set_local $t (i32.add (i32.wrap/i64 (get_local $a3)) (get_local $sp))) 
      (set_local $sign (i64.shr_s (i64.load8_s (get_local $t)) (i64.const 8)))
      (set_local $t (i32.add (get_local $t) (i32.const 1)))
      (block $done
        (loop $loop
          (if (i32.lt_u (get_local $end) (get_local $t))
            (br $done)
          )
          (i64.store (get_local $t) (get_local $sign))
          (set_local $t (i32.add (get_local $t) (i32.const 8)))
          (br $loop)
        )
      )
    )
  )
)

