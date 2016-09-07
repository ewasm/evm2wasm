(import $getBlockHash "ethereum" "getBlockHash" (param i32 i32))
(func $BLOCKHASH
  (param $sp i32)

  (local $a0 i64)
  (local $a1 i64)
  (local $a2 i64)
  (local $a3 i64)

  (set_local $a0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $a2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $a3 (i64.load (get_local $sp)))

  ;; FIXME: to check that we are not overflowing 32 bits
  (call_import $getBlockHash (i32.wrap/i64 (get_local $a3)) (get_local $sp))
)
