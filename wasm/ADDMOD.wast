;; stack:
;;  0: A
;; -1: B
;; -2: MOD
(func $ADDMOD
  (local $sp i32)

  (local $a i64)
  (local $b i64)
  (local $c i64)
  (local $d i64)

  (local $a1 i64)
  (local $b1 i64)
  (local $c1 i64)
  (local $d1 i64)

  (local $moda i64)
  (local $modb i64)
  (local $modc i64)
  (local $modd i64)

  (local $carry i64)

  (set_local $sp (get_global $sp))

  ;; load args from the stack
  (set_local $a (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $b (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $c (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $d (i64.load (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $a1 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $b1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $c1 (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $d1 (i64.load (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $moda (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $modb (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $modc (i64.load (i32.add (get_local $sp) (i32.const 8))))
  (set_local $modd (i64.load (get_local $sp)))

  ;; a * 64^3 + b*64^2 + c*64 + d 
  ;; d 
  (set_local $d     (i64.add (get_local $d1) (get_local $d)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $d) (get_local $d1))))
  ;; c
  (set_local $c     (i64.add (get_local $c) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $c) (get_local $carry))))
  (set_local $c     (i64.add (get_local $c1) (get_local $c)))
  (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $c) (get_local $c1))) (get_local $carry)))
  ;; b
  (set_local $b     (i64.add (get_local $b) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $b) (get_local $carry))))
  (set_local $b     (i64.add (get_local $b1) (get_local $b)))
  (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $b) (get_local $b1))) (get_local $carry)))
  ;; a
  (set_local $a     (i64.add (get_local $a) (get_local $carry)))
  (set_local $carry (i64.extend_u/i32 (i64.lt_u (get_local $a) (get_local $carry))))
  (set_local $a     (i64.add (get_local $a1) (get_local $a)))
  (set_local $carry (i64.or (i64.extend_u/i32  (i64.lt_u (get_local $a) (get_local $a1))) (get_local $carry)))

  (call $mod_320
        (get_local $carry) (get_local $a)    (get_local $b)    (get_local $c)    (get_local $d)
        (i64.const 0)      (get_local $moda) (get_local $modb) (get_local $modc) (get_local $modd) (get_local $sp))
)
