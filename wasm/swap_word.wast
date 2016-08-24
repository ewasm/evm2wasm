(func $swap_word
  (param $sp i32)
  (local $temp i64)

  (set_local $temp (call $bswap_64 (i64.load (get_local $sp))))
  (i64.store (get_local $sp) (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 24)))))
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $temp))

  (set_local $temp (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 8)))))
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (call $bswap_64 (i64.load (i32.add (get_local $sp) (i32.const 16)))))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $temp))
)

(func $bswap_64
  (param $int i64)      
  (result i64)
  
  (i64.or
    (i64.or
      (i64.or
        (i64.and (i64.shr_u (get_local $int) (i64.const 56)) (i64.const 0xff)) ;; 7 -> 0
        (i64.and (i64.shr_u (get_local $int) (i64.const 40)) (i64.const 0xff00))) ;; 6 -> 1
      (i64.or
        (i64.and (i64.shr_u (get_local $int) (i64.const 24)) (i64.const 0xff0000)) ;; 5 -> 2
        (i64.and (i64.shr_u (get_local $int) (i64.const  8)) (i64.const 0xff000000)))) ;; 4 -> 3
    (i64.or
      (i64.or
        (i64.and (i64.shl (get_local $int) (i64.const 8))   (i64.const 0xff00000000)) ;; 3 -> 4
        (i64.and (i64.shl (get_local $int) (i64.const 24))   (i64.const 0xff0000000000))) ;; 2 -> 5
      (i64.or
        (i64.and (i64.shl (get_local $int) (i64.const 40))   (i64.const 0xff000000000000)) ;; 1 -> 6
        (i64.and (i64.shl (get_local $int) (i64.const 56))   (i64.const 0xff00000000000000))))) ;; 0 -> 7
)
