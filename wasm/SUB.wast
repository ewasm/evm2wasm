(func $SUB
  (local $sp i32)

  (local $a i64)
  (local $b i64)
  (local $c i64)
  (local $d i64)

  (local $a1 i64)
  (local $b1 i64)
  (local $c1 i64)
  (local $d1 i64)

  (local $carry i64)
  (local $temp i64)

  (set_local $a (i64.load (i32.add (get_global $sp) (i32.const 24))))
  (set_local $b (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $c (i64.load (i32.add (get_global $sp) (i32.const  8))))
  (set_local $d (i64.load          (get_global $sp)))
  ;; decement the stack pointer
  (set_local $sp (i32.sub (get_global $sp) (i32.const 32)))

  (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $b1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $c1 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $d1 (i64.load          (get_local $sp)))

  ;; a * 64^3 + b*64^2 + c*64 + d 
  ;; d
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $d1))))
  (set_local $d (i64.sub (get_local $d) (get_local $d1)))

  ;; c
  (set_local $temp (i64.sub (get_local $c) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.gt_u (get_local $temp) (get_local $c))))
  (set_local $c (i64.sub (get_local $temp) (get_local $c1)))
  (set_local $carry (i64.or (i64.extend_u/i32 (i64.gt_u (get_local $c) (get_local $temp))) (get_local $carry)))

  ;; b
  (set_local $temp (i64.sub (get_local $b) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.gt_u (get_local $temp) (get_local $b))))
  (set_local $b (i64.sub (get_local $temp) (get_local $b1)))

  ;; a
  (set_local $a (i64.sub (i64.sub (get_local $a) (i64.or (i64.extend_u/i32 (i64.gt_u (get_local $b) (get_local $temp))) (get_local $carry))) (get_local $a1)))

  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $a))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $b))
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (get_local $c))
  (i64.store          (get_local $sp)                 (get_local $d))
)
