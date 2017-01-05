(func $DUP
  (param $a0 i32)
  (local $sp i32)

  (local $sp_ref i32)
  
  (set_local $sp (i32.add (get_global $sp) (i32.const 32)))
  (set_local $sp_ref (i32.sub (i32.sub (get_local $sp) (i32.const 8)) (i32.mul (get_local $a0) (i32.const 32))))
  
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.load (get_local $sp_ref)))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.load (i32.sub (get_local $sp_ref) (i32.const 8))))
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (i64.load (i32.sub (get_local $sp_ref) (i32.const 16))))
  (i64.store          (get_local $sp)                 (i64.load (i32.sub (get_local $sp_ref) (i32.const 24))))
)
