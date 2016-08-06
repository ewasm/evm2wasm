;; MSTORE(word: sp[-1], offset: sp[-2])
(import $print "debug" "print" (param i32))
(func $MSTORE
  (param $sp i32)
  ;;(param $memstart i32)
  (local $memstart i32)
  (local $offset i32)
  (local $word0 i64)
  (local $word1 i64)
  (local $word2 i64)
  (local $word3 i64)
  (local $offset0 i64)
  (local $offset1 i64)
  (local $offset2 i64)
  (local $offset3 i64)
  (result i32)

  ;; Hardcode memory start at 32k: https://github.com/ewasm/evm2wasm/issues/16
  (set_local $memstart (i32.const 32768))


  ;; load args from the stack
  (set_local $offset0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $offset1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $offset2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $offset3 (i64.load          (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $word0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $word1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $word2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $word3 (i64.load          (get_local $sp)))

  ;; FIXME: how to deal with overflow?
  (set_local $offset (i32.add (i32.wrap/i64 (get_local $offset3)) (get_local $memstart)))

  (i64.store          (get_local $offset)                 (get_local $word3))
  (i64.store (i32.add (get_local $offset) (i32.const 8))  (get_local $word2))
  (i64.store (i32.add (get_local $offset) (i32.const 16)) (get_local $word1))
  (i64.store (i32.add (get_local $offset) (i32.const 24)) (get_local $word0))

  (i32.sub (get_local $sp) (i32.const 32))
)

(func $memUseGas
      
)
