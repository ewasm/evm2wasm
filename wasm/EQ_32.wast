(func $eq_i32
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)

  (param $b0 i64)
  (param $b1 i64)
  (param $b2 i64)
  (param $b3 i64)

  (result i32)
  (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == a1
  (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
  (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
           (i64.eq   (get_local $a3) (get_local $b3))))) ;; a3 == b3
)
