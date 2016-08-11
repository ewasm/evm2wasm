;; BYTE(offset: sp[-1], value: sp[-2])
(func $BYTE
  (param $sp i32)
  (result i32)

  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)
  (local $offsetTop i64)

  (local $scratch i32)
  (set_local $scratch (i32.const 32776))

  ;; load args from the stack
  (set_local $offset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $offset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $offset1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $offset0 (i64.load          (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (i64.store (i32.add (get_local $scratch) (i32.const 24)) (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (i64.store (i32.add (get_local $scratch) (i32.const 16)) (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (i64.store (i32.add (get_local $scratch) (i32.const 8))  (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (i64.store          (get_local $scratch)                 (i64.load          (get_local $sp)))

  (set_local $offsetTop (i64.or (get_local $offset1) (i64.or (get_local $offset2) (get_local $offset3))))

  ;; clean the stack
  (i64.store          (get_local $sp)                 (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 8))  (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (i64.const 0))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (i64.const 0))

  ;; if the offset is proper, do the calculation
  (if
    (i32.eqz
      (i32.or
        (i64.gt_u (get_local $offset0) (i64.const 32))
        (i64.gt_u (get_local $offsetTop) (i64.const 0))
      )
    )

    (then
      (i64.store (get_local $sp) (i64.load8_u (i32.add (get_local $scratch) (i32.wrap/i64 (get_local $offset0)))))
    )
  )

  (return (get_local $sp))
)
