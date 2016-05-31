(module
  (memory 1 1)
  (func $and
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.or (get_local $a0) (get_local $b0)))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.and (get_local $a1) (get_local $b1)))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.and (get_local $a2) (get_local $b2)))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.and (get_local $a3) (get_local $b3)))
  )
)
