(func $gte_512
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)
  (param $a4 i64)
  (param $a5 i64)
  (param $a6 i64)
  (param $a7 i64)

  (param $b0 i64)
  (param $b1 i64)
  (param $b2 i64)
  (param $b3 i64)
  (param $b4 i64)
  (param $b5 i64)
  (param $b6 i64)
  (param $b7 i64)

  (result i32)

  ;; a0 > b0 || [a0 == b0 && [a1 > b1 || [a1 == b1 && [a2 > b2 || [a2 == b2 && a3 >= b3 ]]]]
  (i32.or  (i64.gt_u (get_local $a0) (get_local $b0)) ;; a0 > b0
  (i32.and (i64.eq   (get_local $a0) (get_local $b0))
  (i32.or  (i64.gt_u (get_local $a1) (get_local $b1)) ;; a1 > b1
  (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
  (i32.or  (i64.gt_u (get_local $a2) (get_local $b2)) ;; a2 > b2
  (i32.and (i64.eq   (get_local $a2) (get_local $b2))
  (i32.or  (i64.gt_u (get_local $a3) (get_local $b3)) ;; a3 > b3
  (i32.and (i64.eq   (get_local $a3) (get_local $b3))
  (i32.or  (i64.gt_u (get_local $a4) (get_local $b4)) ;; a4 > b4
  (i32.and (i64.eq   (get_local $a4) (get_local $b4))
  (i32.or  (i64.gt_u (get_local $a5) (get_local $b5)) ;; a5 > b5
  (i32.and (i64.eq   (get_local $a5) (get_local $b5))
  (i32.or  (i64.gt_u (get_local $a6) (get_local $b6)) ;; a6 > b6
  (i32.and (i64.eq   (get_local $a6) (get_local $b6))
           (i64.ge_u (get_local $a7) (get_local $b7)))))))))))))))))
