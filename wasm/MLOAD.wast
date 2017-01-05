;; stack:
;;  0: offset
(func $MLOAD
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
  ;; subttract gas useage
  (call $memusegas (get_local $offset) (i32.const  32))

  ;; FIXME: how to deal with overflow?
  (set_local $offset (i32.add (get_local $offset) (get_global $memstart)))

  (i64.store (i32.add (get_global $sp) (i32.const 24)) (i64.load (i32.add (get_local $offset) (i32.const 24))))
  (i64.store (i32.add (get_global $sp) (i32.const 16)) (i64.load (i32.add (get_local $offset) (i32.const 16))))
  (i64.store (i32.add (get_global $sp) (i32.const  8)) (i64.load (i32.add (get_local $offset) (i32.const  8))))
  (i64.store          (get_global $sp)                 (i64.load          (get_local $offset)))

  ;; swap
  (call $bswap_m256 (get_global $sp))
  drop
)
