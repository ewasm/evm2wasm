(func $BLOCKHASH
  (param $sp i32)
  (result i32)

  (local $a0 i64)
  (local $a1 i64)
  (local $a2 i64)
  (local $a3 i64)

  (set_local $a0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $a2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $a3 (i64.load (get_local $sp)))

  (if (i32.and 
        (i32.and 
          (i64.eqz (get_local $a2)) 
          (i64.eqz (get_local $a1)))
        (i64.eqz (get_local $a0)))
    (then
      ;; to check that we are not overflowing 32 bits
      (call_import $blockHash (i32.wrap/i64 (get_local $a3)) (get_local $sp)))
    (else
      ;; zero out the rest of the stack
      (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
      (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
      (i64.store (i32.add (get_local $sp) (i32.const 8))  (i64.const 0))
      (i64.store (get_local $sp) (i64.const 0))
    )
  )
  (return (get_local $sp))
)
