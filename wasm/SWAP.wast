(func $SWAP
  (param $a0 i32)
  (local $sp_ref i32)

  (local $topa i64)
  (local $topb i64)
  (local $topc i64)
  (local $topd i64)
  
  (set_local $sp_ref (i32.sub (i32.add  (get_global $sp) (i32.const 24)) (i32.mul (i32.add (get_local $a0) (i32.const 1)) (i32.const 32))))

  (set_local $topa (i64.load (i32.add (get_global $sp) (i32.const 24))))
  (set_local $topb (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $topc (i64.load (i32.add (get_global $sp) (i32.const  8))))
  (set_local $topd (i64.load          (get_global $sp)))
  
  ;; replace the top element
  (i64.store (i32.add (get_global $sp) (i32.const 24)) (i64.load (get_local $sp_ref)))
  (i64.store (i32.add (get_global $sp) (i32.const 16)) (i64.load (i32.sub (get_local $sp_ref) (i32.const 8))))
  (i64.store (i32.add (get_global $sp) (i32.const  8)) (i64.load (i32.sub (get_local $sp_ref) (i32.const 16))))
  (i64.store          (get_global $sp)                 (i64.load (i32.sub (get_local $sp_ref) (i32.const 24))))

  ;; store the old top element
  (i64.store (get_local $sp_ref)                          (get_local $topa))
  (i64.store (i32.sub (get_local $sp_ref) (i32.const 8))  (get_local $topb))
  (i64.store (i32.sub (get_local $sp_ref) (i32.const 16)) (get_local $topc))
  (i64.store (i32.sub (get_local $sp_ref) (i32.const 24)) (get_local $topd))
)
