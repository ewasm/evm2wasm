;; byte
(func $BYTE
  (param $sp i32)
  (local $a3 i64)

  (set_local $a3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  ;; if (a > 32)
  ;; a0 == 0 && a1 == 0 && a2 == 0 && a3 > 32
  (if 
    (i32.and (i64.gt_u (get_local $a3) (i64.const 32))
    (i32.and (i64.eqz  (i64.load (i32.add (get_local $sp) (i32.const 16))))
    (i32.and (i64.eqz  (i64.load (i32.add (get_local $sp) (i32.const 8))))
             (i64.eqz  (i64.load (get_local $sp))))))
    (return)
  )

  (i64.store (get_local $sp) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 8)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  ;; sp + 32 + a
  (i64.store (i32.add (get_local $sp) (i32.const 24))
             (i64.load8_u  (i32.add (i32.add (i32.wrap/i64 (get_local $a3)) (i32.const 32)) (get_local $sp))))
)
