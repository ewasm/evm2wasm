(func $LT
  (local $sp i32)

  (local $a0 i64)
  (local $a1 i64)
  (local $a2 i64)
  (local $a3 i64)
  (local $b0 i64)
  (local $b1 i64)
  (local $b2 i64)
  (local $b3 i64)

  (set_local $sp (get_global $sp))

  ;; load args from the stack
  (set_local $a0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $a2 (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $a3 (i64.load (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $b0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $b1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $b2 (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $b3 (i64.load (get_local $sp)))

  (i64.store (get_local $sp) (i64.extend_u/i32 
    (i32.or  (i64.lt_u (get_local $a0) (get_local $b0)) ;; a0 < b0
    (i32.and (i64.eq   (get_local $a0) (get_local $b0)) ;; a0 == b0
    (i32.or  (i64.lt_u (get_local $a1) (get_local $b1)) ;; a1 < b1
    (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
    (i32.or  (i64.lt_u (get_local $a2) (get_local $b2)) ;; a2 < b2
    (i32.and (i64.eq   (get_local $a2) (get_local $b2)) ;; a2 == b2
             (i64.lt_u (get_local $a3) (get_local $b3)))))))))) ;; a3 < b3

  ;; zero  out the rest of the stack item
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))
)
