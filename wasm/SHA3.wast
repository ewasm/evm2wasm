(func $SHA3
  (local $dataOffset i32)
  (local $dataOffset0 i64)
  (local $dataOffset1 i64)
  (local $dataOffset2 i64)
  (local $dataOffset3 i64)

  (local $length i32)
  (local $length0 i64)
  (local $length1 i64)
  (local $length2 i64)
  (local $length3 i64)

  (local $contextOffset i32)
  (local $outputOffset i32)

  (set_local $length0 (i64.load (i32.sub (get_global $sp) (i32.const 32))))
  (set_local $length1 (i64.load (i32.sub (get_global $sp) (i32.const 24))))
  (set_local $length2 (i64.load (i32.sub (get_global $sp) (i32.const 16))))
  (set_local $length3 (i64.load (i32.sub (get_global $sp) (i32.const 8))))

  (set_local $dataOffset0 (i64.load (i32.add (get_global $sp) (i32.const 0))))
  (set_local $dataOffset1 (i64.load (i32.add (get_global $sp) (i32.const 8))))
  (set_local $dataOffset2 (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $dataOffset3 (i64.load (i32.add (get_global $sp) (i32.const 24))))

  (set_local $length 
             (call $check_overflow (get_local $length0)
                                   (get_local $length1)
                                   (get_local $length2)
                                   (get_local $length3)))
  (set_local $dataOffset 
             (call $check_overflow (get_local $dataOffset0)
                                   (get_local $dataOffset1)
                                   (get_local $dataOffset2)
                                   (get_local $dataOffset3)))

  ;; charge copy fee ceil(words/32) * 6 
  (call $useGas (i64.extend_u/i32 (i32.mul (i32.div_u (i32.add (get_local $length) (i32.const 31)) (i32.const 32)) (i32.const 6))))
  (call $memusegas (get_local $dataOffset) (get_local $length))

  (set_local $dataOffset (i32.add (get_global $memstart) (get_local $dataOffset)))

  (set_local $contextOffset (i32.const 32808))
  (set_local $outputOffset (i32.sub (get_global $sp) (i32.const 32)))

  (call $keccak (get_local $contextOffset) (get_local $dataOffset) (get_local $length) (get_local $outputOffset))

  (call $bswap_m256 (get_local $outputOffset))
  drop
)
