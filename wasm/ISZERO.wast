(func $ISZERO
  (local $a0 i64)
  (local $a1 i64)
  (local $a2 i64)
  (local $a3 i64)

  ;; load args from the stack
  (set_local $a0 (i64.load (i32.add (get_global $sp) (i32.const 24))))
  (set_local $a1 (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $a2 (i64.load (i32.add (get_global $sp) (i32.const 8))))
  (set_local $a3 (i64.load (get_global $sp)))

  (i64.store (get_global $sp)
    (i64.extend_u/i32
      (call $iszero_256 (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3))
    )
  )

  ;; zero out the rest of memory
  (i64.store (i32.add (get_global $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_global $sp) (i32.const 24)) (i64.const 0))
)
