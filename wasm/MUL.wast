;; Multiplication 0x02 
(func $MUL
  (param $sp i32)
  (result i32)

  (set_local $sp (i32.sub (get_local $sp) (i32.const 8)) )
  (call $MUL_256 
        (i64.load (get_local $sp))
        (i64.load (i32.sub (get_local $sp) (i32.const 8)))
        (i64.load (i32.sub (get_local $sp) (i32.const 16)))
        (i64.load (i32.sub (get_local $sp) (i32.const 24)))
        (i64.load (i32.sub (get_local $sp) (i32.const 32)))
        (i64.load (i32.sub (get_local $sp) (i32.const 40)))
        (i64.load (i32.sub (get_local $sp) (i32.const 48)))
        (i64.load (i32.sub (get_local $sp) (i32.const 56)))
        (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))
  )
  (set_local $sp (i32.add (get_local $sp) (i32.const 8)) )
  (return (get_local $sp))
)
