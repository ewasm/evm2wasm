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

  (set_local $memstart (i32.const 33832))

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
  (call $memUseGas (i32.wrap/i64 (get_local $offset3)))

  (i64.store          (get_local $offset)                 (get_local $word3))
  (i64.store (i32.add (get_local $offset) (i32.const 8))  (get_local $word2))
  (i64.store (i32.add (get_local $offset) (i32.const 16)) (get_local $word1))
  (i64.store (i32.add (get_local $offset) (i32.const 24)) (get_local $word0))

  (i32.sub (get_local $sp) (i32.const 32))
)

(func $memUseGas
  (param $offset i32)
  (local $length i32)

  (local $cost i32)

  ;; what was charged for the last memory allocation
  (local $prevMemCost i32)
  (local $prevMemCostLoc i32)

  ;; the number of 256 words stored in memory
  (local $wordCount i32)
  (local $wordCountLoc i32)

  ;; the base gas fee for storing a word
  (local $wordCost i32)
  ;; the number of new words being allocated
  (local $newWordCount i32)

  (set_local $wordCost (i32.const 3))
  (set_local $length (i32.const 32))

  ;; TODO: dedicate memory for these globals
  (set_local $wordCountLoc   (i32.const 32768))
  (set_local $prevMemCostLoc (i32.const 32772))

  (set_local $wordCount   (i32.load (get_local $wordCountLoc)))
  (set_local $prevMemCost (i32.load (get_local $prevMemCostLoc)))

  ;; const newMemoryWordCount = Math.ceil((offset + length) / 32)
  (set_local $newWordCount (i32.trunc_u/f32 (f32.ceil
                             (f32.div
                               (f32.convert_u/i32
                                 (i32.add (get_local $offset) (get_local $length))) (f32.const 32)))))

  ;;if (runState.highestMem >= highestMem)  return
  (if (i32.lt_u (get_local $newWordCount) (get_local $wordCount))
    (then (return))
  )

  ;; words * 3 + words ^2 / 512
  (set_local $cost  
     (i32.add 
       (i32.mul (get_local $newWordCount) (i32.const 3))
       (i32.div_u (i32.mul (get_local $newWordCount) (get_local $newWordCount)) (i32.const 512))))

  (i32.store (get_local $wordCountLoc) (get_local $newWordCount))
  (i32.store (get_local $prevMemCostLoc) (get_local $cost))

  (call_import $useGas (get_local $cost))
)
