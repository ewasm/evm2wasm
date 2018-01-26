(func $EXP
  (local $sp i32)

  ;; base
  (local $base0 i64)
  (local $base1 i64)
  (local $base2 i64)
  (local $base3 i64)

  ;; exp
  (local $exp0 i64)
  (local $exp1 i64)
  (local $exp2 i64)
  (local $exp3 i64)

  (local $r0 i64)
  (local $r1 i64)
  (local $r2 i64)
  (local $r3 i64)

  (local $gasCounter i32)
  (set_local $sp (get_global $sp))

  ;; load args from the stack
  (set_local $base0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $base1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $base2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $base3 (i64.load          (get_local $sp)))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 32)))

  (set_local $exp0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $exp1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $exp2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $exp3 (i64.load          (get_local $sp)))

  ;; let result = new BN[1]
  (set_local $r3 (i64.const 1))

  (block $done
    (loop $loop
       ;; while [exp > 0] {
      (if (call $iszero_256 (get_local $exp0) (get_local $exp1) (get_local $exp2) (get_local $exp3))
        (br $done) 
      )

      ;; if[exp.modn[2] === 1]
      ;; is odd?
      (if (i64.eqz (i64.ctz (get_local $exp3)))

        ;; result = result.mul[base].mod[TWO_POW256]
        ;; r = r * a
        (then
          (call $mul_256 (get_local $r0) (get_local $r1) (get_local $r2) (get_local $r3) (get_local $base0) (get_local $base1) (get_local $base2) (get_local $base3) (i32.add (get_local $sp) (i32.const 24)))
          (set_local $r0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
          (set_local $r1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
          (set_local $r2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
          (set_local $r3 (i64.load          (get_local $sp)))
        )
      )
      ;; exp = exp.shrn 1
      (set_local $exp3 (i64.add (i64.shr_u (get_local $exp3) (i64.const 1)) (i64.shl (get_local $exp2) (i64.const 63))))
      (set_local $exp2 (i64.add (i64.shr_u (get_local $exp2) (i64.const 1)) (i64.shl (get_local $exp1) (i64.const 63))))
      (set_local $exp1 (i64.add (i64.shr_u (get_local $exp1) (i64.const 1)) (i64.shl (get_local $exp0) (i64.const 63))))
      (set_local $exp0 (i64.shr_u (get_local $exp0) (i64.const 1)))

      ;; base = base.mulr[baser].modr[TWO_POW256]
      (call $mul_256 (get_local $base0) (get_local $base1) (get_local $base2) (get_local $base3) (get_local $base0) (get_local $base1) (get_local $base2) (get_local $base3) (i32.add (get_local $sp) (i32.const 24)))
      (set_local $base0 (i64.load (i32.add (get_local $sp) (i32.const 24))))
      (set_local $base1 (i64.load (i32.add (get_local $sp) (i32.const 16))))
      (set_local $base2 (i64.load (i32.add (get_local $sp) (i32.const  8))))
      (set_local $base3 (i64.load          (get_local $sp)))

      (set_local $gasCounter (i32.add (get_local $gasCounter) (i32.const 1)))
      (br $loop)
    )
  ) 

  ;; use gas
  ;; Log256[Exponent] * 10
  (call $useGas
    (i64.extend_u/i32
      (i32.mul
        (i32.const 10)
        (i32.div_u
          (i32.add (get_local $gasCounter) (i32.const 7))
          (i32.const 8)))))

  ;; decement the stack pointer
  (i64.store (i32.add (get_local $sp) (i32.const 24)) (get_local $r0))
  (i64.store (i32.add (get_local $sp) (i32.const 16)) (get_local $r1))
  (i64.store (i32.add (get_local $sp) (i32.const  8)) (get_local $r2))
  (i64.store          (get_local $sp)                 (get_local $r3))
)
