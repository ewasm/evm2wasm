(func $memusegas
  (param $offset i32)
  (param $length i32)

  (local $cost i64)
  ;; the number of new words being allocated
  (local $newWordCount i32)

  (if (i32.eqz (get_local $length))
    (then (return))
  )

  ;; const newMemoryWordCount = Math.ceil[[offset + length] / 32]
  (set_local $newWordCount (i32.div_u (i32.add (i32.const 31) (i32.add (get_local $offset) (get_local $length))) (i32.const 32)))
  ;;if [runState.highestMem >= highestMem]  return
  (if (i32.le_u (get_local $newWordCount) (get_global $wordCount))
    (then (return))
  )


  ;; words * 3 + words ^2 / 512
  (set_local $cost
     (i64.add
       (i64.extend_u/i32 (i32.mul (get_local $newWordCount) (i32.const 3)))
       (i64.div_u
         (i64.mul (i64.extend_u/i32 (get_local $newWordCount))
                  (i64.extend_u/i32 (get_local $newWordCount)))
         (i64.const 512))))

  (set_local $cost (i64.sub (get_local $cost) (get_global $prevMemCost)))
  (set_global $prevMemCost (get_local $cost))

  (call $useGas  (get_local $cost))
  (set_global $wordCount (get_local $newWordCount))

  ;; grow actual memory
  ;; the first 31704 bytes are guaranteed to be available
  ;; adjust for 32 bytes  - the maximal size of MSTORE write
  ;; TODO it should be current_memory * page_size
  (set_local $offset (i32.add (get_local $length) (i32.add (get_local $offset) (get_global $memstart))))
  (if (i32.gt_u (get_local $offset) (i32.mul (i32.const 65536) (current_memory)))
    (then
      (grow_memory
        (i32.div_u (i32.add (i32.const 65535) (i32.sub (get_local $offset) (current_memory))) (i32.const 65536)))
      drop
    )
  )
)
