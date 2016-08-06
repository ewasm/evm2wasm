;; MLOAD(offset: sp[-2])
(func $MLOAD
  (param $sp i32)
  ;;(param $memstart i32)
  (local $memstart i32)
  (local $offset i32)
  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)
  (result i32)

  (set_local $sp (i32.add (get_local $sp) (i32.const 24)))
  ;; Hardcode memory start at 32k: https://github.com/ewasm/evm2wasm/issues/16
  (set_local $memstart (i32.const 32768))

  ;; load args from the stack
  (set_local $offset0 (i64.load (get_local $sp)))
  (set_local $offset1 (i64.load (i32.sub (get_local $sp) (i32.const 8))))
  (set_local $offset2 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $offset3 (i64.load (i32.sub (get_local $sp) (i32.const 24))))

  ;; FIXME: how to deal with overflow?
  (set_local $offset (i32.add (i32.wrap/i64 (get_local $offset3)) (get_local $memstart)))

  (i64.store (get_local $sp) (i64.load (i32.add (get_local $offset) (i32.const 24))))
  (i64.store (i32.sub (get_local $sp) (i32.const 8)) (i64.load (i32.add (get_local $offset) (i32.const 16))))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (i64.load (i32.add (get_local $offset) (i32.const 8))))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (i64.load (get_local $offset)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 24)))
  (return (get_local $sp))
)
