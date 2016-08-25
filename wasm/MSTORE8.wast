;; MSTORE8(word: sp[-1], offset: sp[-2])
(func $MSTORE8
  (param $sp i32)
  (result i32)

  (local $offset i32)

  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)

  (set_local $offset (i32.const 33832))

  ;; load args from the stack
  (set_local $offset0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $offset1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $offset2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $offset3 (i64.load          (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  ;; FIXME: how to deal with overflow?
  (set_local $offset (i32.add (i32.wrap/i64 (get_local $offset3)) (get_local $offset)))
  (call $memUseGas  (i32.wrap/i64 (get_local $offset3)) (i32.const 8))

  (i32.store8 (i32.add (get_local $offset) (i32.const 0)) (i32.load (get_local $sp)))

  (i32.sub (get_local $sp) (i32.const 32))
)
