(func $bswap_i32
  (param $int i32)
  (result i32)

  (i32.or
    (i32.or
      (i32.and (i32.shr_u (get_local $int) (i32.const 24)) (i32.const 0xff)) ;; 7 -> 0
      (i32.and (i32.shr_u (get_local $int) (i32.const 8)) (i32.const 0xff00))) ;; 6 -> 1
    (i32.or
      (i32.and (i32.shl (get_local $int) (i32.const 8)) (i32.const 0xff0000)) ;; 5 -> 2
      (i32.and (i32.shl (get_local $int) (i32.const 24)) (i32.const 0xff000000))))) ;; 4 -> 3
   
