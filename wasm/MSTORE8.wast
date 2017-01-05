;; stack:
;;  0: word
;; -1: offset
(func $MSTORE8
  (local $sp i32)

  (local $offset i32)

  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)

  ;; load args from the stack
  (set_local $offset0 (i64.load          (get_global $sp)))
  (set_local $offset1 (i64.load (i32.add (get_global $sp) (i32.const 8))))
  (set_local $offset2 (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $offset3 (i64.load (i32.add (get_global $sp) (i32.const 24))))

  (set_local $offset 
             (call $check_overflow (get_local $offset0)
                                   (get_local $offset1)
                                   (get_local $offset2)
                                   (get_local $offset3)))

  (call $memusegas (get_local $offset) (i32.const 8))

  ;; pop stack
  (set_local $sp (i32.sub (get_global $sp) (i32.const 32)))
  (set_local $offset (i32.add (get_local $offset) (get_global $memstart)))
  (i32.store8 (i32.add (get_local $offset) (i32.const 0)) (i32.load (get_local $sp)))
)
