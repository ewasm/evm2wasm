;; MSTORE(word: sp[-1], offset: sp[-2])
(func $MSTORE
  (param $sp i32)
  (result i32)

  (local $memstart i32)
  (local $offset   i32)
  
  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)

  (set_local $memstart (i32.const 33832))

  ;; load args from the stack
  (set_local $offset0 (i64.load          (get_local $sp)))
  (set_local $offset1 (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $offset2 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $offset3 (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (set_local $offset 
             (call $check_overflow (get_local $offset0)
                                   (get_local $offset1)
                                   (get_local $offset2)
                                   (get_local $offset3)))
  ;; subtrace gas useage
  (call $memUseGas (get_local $offset) (i32.const 32))

  ;; pop itme from the stack
  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  ;; swap top stack item
  (call $swap_word (get_local $sp))

  ;; FIXME: how to deal with overflow?
  (set_local $offset (i32.add (get_local $offset) (get_local $memstart)))


  ;; store word to memory
  (i64.store          (get_local $offset)                 (i64.load          (get_local $sp)))
  (i64.store (i32.add (get_local $offset) (i32.const 8))  (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (i64.store (i32.add (get_local $offset) (i32.const 16)) (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (i64.store (i32.add (get_local $offset) (i32.const 24)) (i64.load (i32.add (get_local $sp) (i32.const 24))))

  (i32.sub (get_local $sp) (i32.const 32))
)
