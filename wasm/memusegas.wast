(func $memUseGas
  (param $offset i32)
  (param $length i32)

  (local $memstart i32)
  (local $cost i64)

  ;; what was charged for the last memory allocation
  (local $prevMemCost i64)
  (local $prevMemCostLoc i32)

  ;; the number of 256 words stored in memory
  (local $wordCount i32)
  (local $wordCountLoc i32)

  ;; the number of new words being allocated
  (local $newWordCount i32)

  (if (i32.eqz (get_local $length))
    (then (return))
  )

  ;; set globals
  (set_local $memstart (i32.const 33832))
  (set_local $wordCountLoc   (i32.const 32768))
  (set_local $prevMemCostLoc (i32.const 32772))

  (set_local $wordCount   (i32.load (get_local $wordCountLoc)))
  (set_local $prevMemCost (i64.load (get_local $prevMemCostLoc)))

  ;; const newMemoryWordCount = Math.ceil[[offset + length] / 32]
  (set_local $newWordCount (i32.trunc_u/f32 (f32.ceil
                             (f32.div
                               (f32.convert_u/i32
                                 (i32.add (get_local $offset) (get_local $length))) (f32.const 32)))))
  ;;if [runState.highestMem >= highestMem]  return
  (if (i32.le_u (get_local $newWordCount) (get_local $wordCount))
    (then (return))
  )

  ;; words * 3 + words ^2 / 512
  (set_local $cost
     (i64.add
       (i64.extend_u/i32 (i32.mul (get_local $newWordCount) (i32.const 3)))
       (i64.div_u (i64.mul (i64.extend_u/i32 (get_local $newWordCount)) (i64.extend_u/i32 (get_local $newWordCount))) (i64.const 512))))

  (i64.store (get_local $prevMemCostLoc) (get_local $cost))
  (set_local $cost (i64.sub (get_local $cost) (get_local $prevMemCost)))

  ;; TODO remove once useGas can use i64
  (loop $done $loop
    (if (i64.le_u (get_local $cost) (i64.const 0xffffffff))
      (then (br $done))  
    )
    (call_import $useGas  (i32.const 0xffffffff))
    (set_local $cost (i64.sub (get_local $cost) (i64.const 0xffffffff)))
    (br $loop)
  )

  (call_import $useGas  (i32.wrap/i64 (get_local $cost)))

  (i32.store (get_local $wordCountLoc) (get_local $newWordCount))

  ;; grow actual memory
  ;; the first 31704 bytes are guaranteed to be available
  ;; adjust for 32 bytes  - the maximal size of MSTORE write
  ;; TODO it should be current_memory * page_size
  (set_local $offset (i32.add (get_local $length) (i32.add (get_local $offset) (get_local $memstart))))
  (if (i32.gt_u (get_local $offset) (current_memory))
    (then
      (grow_memory 
        (i32.div_u (i32.add (i32.const 65535) (i32.sub (get_local $offset) (current_memory))) (i32.const 65536)))
    )
  )
)
