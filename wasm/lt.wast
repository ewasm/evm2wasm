(module
  (memory 1 1)
  (func $lt
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)
    (param $sp i32)

    (i64.store (get_local $sp) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
    (i64.store (i32.add (get_local $sp) (i32.const 24)) 
      (i64.extend/i32
        (call $lt_i32 (get_local 0) (get_local 1)(get_local 2)(get_local 3)(get_local 4)(get_local 5)(get_local 6)(get_local 7))
      )
    )
  )
  (func $lt_i32
    (param $a0 i64)
    (param $a1 i64)
    (param $a2 i64)
    (param $a3 i64)
 
    (param $b0 i64)
    (param $b1 i64)
    (param $b2 i64)
    (param $b3 i64)

    (result i32)
    ;; a0 < b0 || (a0 == b0 && (a1 < b1 || (a1 == b1 && (a2 < b2 || (a2 == b2 && a3 < b3 ) ))))
    (i32.or  (i64.lt_u (get_local $a0) (get_local $b0)) ;; a0 < b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == b0
    (i32.or  (i64.lt_u (get_local $a1) (get_local $b1)) ;; a1 < b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.lt_u (get_local $a2) (get_local $b2)) ;; a2 < b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.lt_u (get_local $a3) (get_local $b3)))))))) ;; a3 < b3
  )
  (export "lt" $lt)
)
