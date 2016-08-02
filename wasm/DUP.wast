(func $DUP
  (param $a0 i64)
  (param $sp i32)
  (local $sp_ref i32)
  (result i32)
  
  (set_local $sp_ref (i32.sub (get_local $sp) (i32.mul (i32.wrap/i64 (get_local $a0)) (i32.const 32))))

  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))
  
  ;; FIXME: remove const0
  (i64.store (i32.sub (get_local $sp) (i32.const 0))  (i64.load (i32.sub (get_local $sp_ref) (i32.const 0))))
  (i64.store (i32.sub (get_local $sp) (i32.const 8))  (i64.load (i32.sub (get_local $sp_ref) (i32.const 8))))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (i64.load (i32.sub (get_local $sp_ref) (i32.const 16))))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (i64.load (i32.sub (get_local $sp_ref) (i32.const 24))))
  
  (return (get_local $sp))
)
