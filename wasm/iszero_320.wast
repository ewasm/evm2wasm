(func $iszero_320
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (result i32)

  (i64.eqz (i64.or (i64.or (i64.or (i64.or (get_local 0) (get_local 1)) (get_local 2)) (get_local 3)) (get_local 4)))
)
