;; Exponential 0x0a
(func $EXP
  (param $sp i32)
  (result i32)

  ;; base
  (local $a0 i64)
  (local $a1 i64)
  (local $a2 i64)
  (local $a3 i64)

  ;; exp
  (local $b0 i64)
  (local $b1 i64)
  (local $b2 i64)
  (local $b3 i64)

  (local $r0 i64)
  (local $r1 i64)
  (local $r2 i64)
  (local $r3 i64)

  (set_local $sp (i32.sub (get_local $sp) (i32.const 8)) )

  ;; load args from the stack
  (set_local $a0 (i64.load (get_local $sp)))
  (set_local $a1 (i64.load (i32.sub (get_local $sp) (i32.const 8))))
  (set_local $a2 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $a3 (i64.load (i32.sub (get_local $sp) (i32.const 24))))

  (set_local $b0 (i64.load (i32.sub (get_local $sp) (i32.const 32))))
  (set_local $b1 (i64.load (i32.sub (get_local $sp) (i32.const 40))))
  (set_local $b2 (i64.load (i32.sub (get_local $sp) (i32.const 48))))
  (set_local $b3 (i64.load (i32.sub (get_local $sp) (i32.const 56))))

  ;; let result = new BN(1)
  (set_local $r3 (i64.const 1))

  (loop $done $loop
     ;; while (exp > 0) {
    (if (call $isZero_i32 (get_local $b0) (get_local $b1) (get_local $b2) (get_local $b3))
      (br $done) 
    )
    
    ;; if(exp.modn(2) === 1)
    ;; is odd?
    (if (i64.eqz (i64.ctz (get_local $b3)))
      ;; result = result.mul(base).mod(TWO_POW256)
      ;; r = r * a
      (then
        (call $MUL_256 (get_local $r0) (get_local $r1) (get_local $r2) (get_local $r3) (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3) (get_local $sp))
        (set_local $r0 (i64.load (get_local $sp)))
        (set_local $r1 (i64.load (i32.sub (get_local $sp) (i32.const 8))))
        (set_local $r2 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
        (set_local $r3 (i64.load (i32.sub (get_local $sp) (i32.const 24))))
      )
    )
    ;; exp = exp.shrn(1)
    (set_local $b0 (i64.shr_u (get_local $b0) (i64.const 1)))
    (set_local $b1 (i64.shr_u (get_local $b1) (i64.const 1)))
    (set_local $b2 (i64.shr_u (get_local $b2) (i64.const 1)))
    (set_local $b3 (i64.shr_u (get_local $b3) (i64.const 1)))

    ;; base = base.mul(base).mod(TWO_POW256)
    (call $MUL_256 (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3) (get_local $a0) (get_local $a1) (get_local $a2) (get_local $a3) (get_local $sp))
    (set_local $a0 (i64.load (get_local $sp)))
    (set_local $a1 (i64.load (i32.sub (get_local $sp) (i32.const 8))))
    (set_local $a2 (i64.load (i32.sub (get_local $sp) (i32.const 16))))
    (set_local $a3 (i64.load (i32.sub (get_local $sp) (i32.const 24))))
    (br $loop)
  ) 

  ;; decement the stack pointer
  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (i64.store (get_local $sp) (get_local $r0))
  (i64.store (i32.sub (get_local $sp) (i32.const 8)) (get_local $r1))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (get_local $r2))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (get_local $r3))

  (set_local $sp (i32.add (get_local $sp) (i32.const 8)) )
  (get_local $sp)
)
