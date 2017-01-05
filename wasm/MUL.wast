(func $MUL
  (call $mul_256
        (i64.load (i32.add (get_global $sp) (i32.const 24)))
        (i64.load (i32.add (get_global $sp) (i32.const 16)))
        (i64.load (i32.add (get_global $sp) (i32.const  8)))
        (i64.load          (get_global $sp))
        (i64.load (i32.sub (get_global $sp) (i32.const  8)))
        (i64.load (i32.sub (get_global $sp) (i32.const 16)))
        (i64.load (i32.sub (get_global $sp) (i32.const 24)))
        (i64.load (i32.sub (get_global $sp) (i32.const 32)))
        (i32.sub (get_global $sp) (i32.const 8))
  )
)
