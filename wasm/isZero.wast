(module
  (memory 1 1)
  (func $isZero
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)

    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend/i32
        (call $isZero_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )
  (func $isZero_i32
    (param i64)
    (param i64)
    (param i64)
    (param i64)
    (result i32)
    (i64.eqz (i64.or (i64.or (i64.or (get_local 0) (get_local 1)) (get_local 2)) (get_local 3))) 
  )
  (export "gt" $gt)
)
