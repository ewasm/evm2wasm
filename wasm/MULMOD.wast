(func $MULMOD
  (param $sp i32)

  (local $a i64)
  (local $c i64)
  (local $e i64)
  (local $g i64)
  (local $i i64)
  (local $k i64)
  (local $m i64)
  (local $o i64)
  (local $b i64)
  (local $d i64)
  (local $f i64)
  (local $h i64)
  (local $j i64)
  (local $l i64)
  (local $n i64)
  (local $p i64)
  (local $temp7 i64)
  (local $temp6 i64)
  (local $temp5 i64)
  (local $temp4 i64)
  (local $temp3 i64)
  (local $temp2 i64)
  (local $temp1 i64)
  (local $temp0 i64)
  (local $rowCarry i64)

  (local $moda i64)
  (local $modb i64)
  (local $modc i64)
  (local $modd i64)

  ;; pop two items of the stack
  (set_local $a (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $c (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $e (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $g (i64.load          (get_local $sp)))
  (set_local $i (i64.load (i32.sub (get_local $sp) (i32.const  8))))
  (set_local $k (i64.load (i32.sub (get_local $sp) (i32.const 16))))
  (set_local $m (i64.load (i32.sub (get_local $sp) (i32.const 24))))
  (set_local $o (i64.load (i32.sub (get_local $sp) (i32.const 32))))

  (set_local $sp (i32.sub (get_local $sp) (i32.const 64)))

  ;; MUL
  ;;  a b c d e f g h
  ;;* i j k l m n o p
  ;;----------------

  ;; split the ops
  (set_local $b (i64.and (get_local $a) (i64.const 4294967295)))
  (set_local $a (i64.shr_u (get_local $a) (i64.const 32))) 

  (set_local $d (i64.and (get_local $c) (i64.const 4294967295)))
  (set_local $c (i64.shr_u (get_local $c) (i64.const 32))) 

  (set_local $f (i64.and (get_local $e) (i64.const 4294967295)))
  (set_local $e (i64.shr_u (get_local $e) (i64.const 32)))

  (set_local $h (i64.and (get_local $g) (i64.const 4294967295)))
  (set_local $g (i64.shr_u (get_local $g) (i64.const 32)))

  (set_local $j (i64.and (get_local $i) (i64.const 4294967295)))
  (set_local $i (i64.shr_u (get_local $i) (i64.const 32))) 

  (set_local $l (i64.and (get_local $k) (i64.const 4294967295)))
  (set_local $k (i64.shr_u (get_local $k) (i64.const 32))) 

  (set_local $n (i64.and (get_local $m) (i64.const 4294967295)))
  (set_local $m (i64.shr_u (get_local $m) (i64.const 32)))

  (set_local $p (i64.and (get_local $o) (i64.const 4294967295)))
  (set_local $o (i64.shr_u (get_local $o) (i64.const 32)))

   ;; first row multiplication 
  ;; p * h
  (set_local $temp0 (i64.mul (get_local $p) (get_local $h)))
  ;; p * g + carry
  (set_local $temp1 (i64.add (i64.mul (get_local $p) (get_local $g)) (i64.shr_u (get_local $temp0) (i64.const 32))))
  ;; p * f + carry
  (set_local $temp2 (i64.add (i64.mul (get_local $p) (get_local $f)) (i64.shr_u (get_local $temp1) (i64.const 32))))
  ;; p * e + carry
  (set_local $temp3 (i64.add (i64.mul (get_local $p) (get_local $e)) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; p * d + carry
  (set_local $temp4 (i64.add (i64.mul (get_local $p) (get_local $d)) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; p * c + carry
  (set_local $temp5 (i64.add (i64.mul (get_local $p) (get_local $c)) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; p * b + carry
  (set_local $temp6 (i64.add (i64.mul (get_local $p) (get_local $b)) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; p * a + carry
  (set_local $temp7 (i64.add (i64.mul (get_local $p) (get_local $a)) (i64.shr_u (get_local $temp6) (i64.const 32))))
  (set_local $rowCarry (i64.shr_u (get_local $temp7) (i64.const 32)))

  ;; second row
  ;; o * h + $temp1 (pg)
  (set_local $temp1 (i64.add (i64.mul (get_local $o) (get_local $h)) (i64.and (get_local $temp1) (i64.const 4294967295))))
  ;; o * g + $temp2 (pf) + carry
  (set_local $temp2 (i64.add (i64.add (i64.mul (get_local $o) (get_local $g)) (i64.and (get_local $temp2) (i64.const 4294967295))) (i64.shr_u (get_local $temp1) (i64.const 32))))
  ;; o * f + $temp3 (pe) + carry
  (set_local $temp3 (i64.add (i64.add (i64.mul (get_local $o) (get_local $f)) (i64.and (get_local $temp3) (i64.const 4294967295))) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; o * e + $temp4 (pd) + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $o) (get_local $e)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; o * d + $temp5 (pc) + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $o) (get_local $d)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; o * c + $temp6 (pb) + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $o) (get_local $c)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; o * b + $temp7 (pa) + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $o) (get_local $b)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; o * a + carry + rowCarry
  (set_local $p (i64.add (i64.add (i64.mul (get_local $o) (get_local $a)) (i64.shr_u (get_local $temp7) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $p) (i64.const 32)))

  ;; third row - n
  ;; n * h + $temp2 (og)
  (set_local $temp2 (i64.add (i64.mul (get_local $n) (get_local $h)) (i64.and (get_local $temp2) (i64.const 4294967295))))
  ;; n * g + $temp3 (of) + carry
  (set_local $temp3 (i64.add (i64.add (i64.mul (get_local $n) (get_local $g)) (i64.and (get_local $temp3) (i64.const 4294967295))) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; n * f + $temp4 (oe) + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $n) (get_local $f)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; n * e + $temp5 (od) + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $n) (get_local $e)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; n * d + $temp6 (oc) + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $n) (get_local $d)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; n * c + $temp7 (ob) + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $n) (get_local $c)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; n * b + $p (oa) + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $n) (get_local $b)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; n * a + carry
  (set_local $o (i64.add (i64.add (i64.mul (get_local $n) (get_local $a)) (i64.shr_u (get_local $p) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $o) (i64.const 32)))

  ;; forth row 
  ;; m * h + $temp3 (ng)
  (set_local $temp3 (i64.add (i64.mul (get_local $m) (get_local $h)) (i64.and (get_local $temp3) (i64.const 4294967295))))
  ;; m * g + $temp4 (nf) + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $m) (get_local $g)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; m * f + $temp5 (ne) + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $m) (get_local $f)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; m * e + $temp6 (nd) + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $m) (get_local $e)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; m * d + $temp7 (nc) + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $m) (get_local $d)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; m * c + $p (nb) + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $m) (get_local $c)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; m * b + $o (na) + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $m) (get_local $b)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; m * a + carry + rowCarry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $m) (get_local $a)) (i64.shr_u (get_local $o) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $n) (i64.const 32)))

  ;; fith row
  ;; l * h + $temp4 (mg)
  (set_local $temp4 (i64.add (i64.mul (get_local $l) (get_local $h)) (i64.and (get_local $temp4) (i64.const 4294967295))))
  ;; l * g + $temp5 (mf) + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $l) (get_local $g)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; l * f + $temp6 (me) + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $l) (get_local $f)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; l * e + $temp7 (md) + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $l) (get_local $e)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; l * d + $p (mc) + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $l) (get_local $d)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; l * c + $o (mb) + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $l) (get_local $c)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; l * b + $n (ma) + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $l) (get_local $b)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; l * a + carry + rowCarry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $l) (get_local $a)) (i64.shr_u (get_local $n) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $m) (i64.const 32)))

  ;; sixth row 
  ;; k * h + $temp5 (lg)
  (set_local $temp5 (i64.add (i64.mul (get_local $k) (get_local $h)) (i64.and (get_local $temp5) (i64.const 4294967295))))
  ;; k * g + $temp6 (lf) + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $k) (get_local $g)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; k * f + $temp7 (le) + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $k) (get_local $f)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; k * e + $p (ld) + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $k) (get_local $e)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; k * d + $o (lc) + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $k) (get_local $d)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; k * c + $n (lb) + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $k) (get_local $c)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; k * b + $m (la) + carry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $k) (get_local $b)) (i64.and (get_local $m)     (i64.const 4294967295))) (i64.shr_u (get_local $n)     (i64.const 32))))
  ;; k * a + carry
  (set_local $l     (i64.add (i64.add (i64.mul (get_local $k) (get_local $a)) (i64.shr_u (get_local $m) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $l) (i64.const 32)))

  ;; seventh row
  ;; j * h + $temp6 (kg)
  (set_local $temp6 (i64.add (i64.mul (get_local $j) (get_local $h)) (i64.and (get_local $temp6) (i64.const 4294967295))))
  ;; j * g + $temp7 (kf) + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $j) (get_local $g)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; j * f + $p (ke) + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $j) (get_local $f)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; j * e + $o (kd) + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $j) (get_local $e)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; j * d + $n (kc) + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $j) (get_local $d)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; j * c + $m (kb) + carry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $j) (get_local $c)) (i64.and (get_local $m)     (i64.const 4294967295))) (i64.shr_u (get_local $n)     (i64.const 32))))
  ;; j * b + $l (ka) + carry
  (set_local $l     (i64.add (i64.add (i64.mul (get_local $j) (get_local $b)) (i64.and (get_local $l)     (i64.const 4294967295))) (i64.shr_u (get_local $m)     (i64.const 32))))
  ;; j * a + carry
  (set_local $k     (i64.add (i64.add (i64.mul (get_local $j) (get_local $a)) (i64.shr_u (get_local $l) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $k) (i64.const 32)))

  ;; eigth row
  ;; i * h + $temp7 (jg)
  (set_local $temp7 (i64.add (i64.mul (get_local $i) (get_local $h)) (i64.and (get_local $temp7) (i64.const 4294967295))))
  ;; i * g + $p (jf) 
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $i) (get_local $g)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; i * f + $o (je) + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $i) (get_local $f)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; i * e + $n (jd) + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $i) (get_local $e)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; i * d + $m (jc) + carry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $i) (get_local $d)) (i64.and (get_local $m)     (i64.const 4294967295))) (i64.shr_u (get_local $n)     (i64.const 32))))
  ;; i * c + $l (jb) + carry
  (set_local $l     (i64.add (i64.add (i64.mul (get_local $i) (get_local $c)) (i64.and (get_local $l)     (i64.const 4294967295))) (i64.shr_u (get_local $m)     (i64.const 32))))
  ;; i * b + $k (ja) + carry
  (set_local $k     (i64.add (i64.add (i64.mul (get_local $i) (get_local $b)) (i64.and (get_local $k)     (i64.const 4294967295))) (i64.shr_u (get_local $l)     (i64.const 32))))
  ;; i * a + carry
  (set_local $j     (i64.add (i64.add (i64.mul (get_local $i) (get_local $a)) (i64.shr_u (get_local $k) (i64.const 32))) (get_local $rowCarry)))

  ;; combine terms
  (set_local $a (get_local $j))
  (set_local $b (i64.or (i64.shl (get_local $k)     (i64.const 32)) (i64.and (get_local $l)     (i64.const 4294967295))))
  (set_local $c (i64.or (i64.shl (get_local $m)     (i64.const 32)) (i64.and (get_local $n)     (i64.const 4294967295))))
  (set_local $d (i64.or (i64.shl (get_local $o)     (i64.const 32)) (i64.and (get_local $p)     (i64.const 4294967295))))
  (set_local $e (i64.or (i64.shl (get_local $temp7) (i64.const 32)) (i64.and (get_local $temp6) (i64.const 4294967295))))
  (set_local $f (i64.or (i64.shl (get_local $temp5) (i64.const 32)) (i64.and (get_local $temp4) (i64.const 4294967295))))
  (set_local $g (i64.or (i64.shl (get_local $temp3) (i64.const 32)) (i64.and (get_local $temp2) (i64.const 4294967295))))
  (set_local $h (i64.or (i64.shl (get_local $temp1) (i64.const 32)) (i64.and (get_local $temp0) (i64.const 4294967295))))

  ;; pop the MOD argmunet off the stack

  (set_local $moda (i64.load (i32.add (get_local $sp) (i32.const 24))))
  (set_local $modb (i64.load (i32.add (get_local $sp) (i32.const 16))))
  (set_local $modc (i64.load (i32.add (get_local $sp) (i32.const  8))))
  (set_local $modd (i64.load          (get_local $sp)))

  (call $MOD_512
         (get_local $a) (get_local $b) (get_local $c) (get_local $d) (get_local $e) (get_local $f) (get_local $g) (get_local $h) 
         (i64.const 0)  (i64.const 0) (i64.const 0)  (i64.const 0)  (get_local $moda) (get_local $modb) (get_local $modc) (get_local $modd) (i32.add (get_local $sp) (i32.const 24))
  )
)


;; Modulo 0x06
(func $MOD_512
  ;; dividend
  (param $a i64)
  (param $b i64)
  (param $c i64)
  (param $d i64)
  (param $e i64)
  (param $f i64)
  (param $g i64)
  (param $h i64)

  ;; divisor
  (param $a1 i64)
  (param $b1 i64)
  (param $c1 i64)
  (param $d1 i64)
  (param $e1 i64)
  (param $f1 i64)
  (param $g1 i64)
  (param $h1 i64)

  (param $sp i32)
  (result i32)

  ;; quotient
  (local $aq i64)
  (local $bq i64)
  (local $cq i64)
  (local $dq i64)

  ;; mask
  (local $maska i64)
  (local $maskb i64)
  (local $maskc i64)
  (local $maskd i64)
  (local $maske i64)
  (local $maskf i64)
  (local $maskg i64)
  (local $maskh i64)

  (local $carry i32)
  (local $temp i64)

  (set_local $maskh (i64.const 1))

  (block $main
    ;; check div by 0
    (if (call $isZero_512 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $e1) (get_local $f1) (get_local $g1) (get_local $h1))
      (then
        (set_local $e (i64.const 0))
        (set_local $f (i64.const 0))
        (set_local $g (i64.const 0))
        (set_local $h (i64.const 0))
        (br $main)
      )
    )

    ;; align bits
    (loop $done $loop
      ;; align bits;
      (if (i32.or (i64.eqz (i64.clz (get_local $a1)))
        (call $gte_512 (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $e1) (get_local $f1) (get_local $g1) (get_local $h1)
                       (get_local $a)  (get_local $b)  (get_local $c)  (get_local $d)  (get_local $e)  (get_local $f)  (get_local $g)  (get_local $h)))
        (br $done)
      )

      ;; divisor = divisor << 1
      (set_local $a1 (i64.add (i64.shl (get_local $a1) (i64.const 1)) (i64.shr_u (get_local $b1) (i64.const 63))))
      (set_local $b1 (i64.add (i64.shl (get_local $b1) (i64.const 1)) (i64.shr_u (get_local $c1) (i64.const 63))))
      (set_local $c1 (i64.add (i64.shl (get_local $c1) (i64.const 1)) (i64.shr_u (get_local $d1) (i64.const 63))))
      (set_local $d1 (i64.add (i64.shl (get_local $d1) (i64.const 1)) (i64.shr_u (get_local $e1) (i64.const 63))))
      (set_local $e1 (i64.add (i64.shl (get_local $e1) (i64.const 1)) (i64.shr_u (get_local $f1) (i64.const 63))))
      (set_local $f1 (i64.add (i64.shl (get_local $f1) (i64.const 1)) (i64.shr_u (get_local $g1) (i64.const 63))))
      (set_local $g1 (i64.add (i64.shl (get_local $g1) (i64.const 1)) (i64.shr_u (get_local $h1) (i64.const 63))))
      (set_local $h1 (i64.shl (get_local $h1) (i64.const 1)))

      ;; mask = mask << 1
      (set_local $maska (i64.add (i64.shl (get_local $maska) (i64.const 1)) (i64.shr_u (get_local $maskb) (i64.const 63))))
      (set_local $maskb (i64.add (i64.shl (get_local $maskb) (i64.const 1)) (i64.shr_u (get_local $maskc) (i64.const 63))))
      (set_local $maskc (i64.add (i64.shl (get_local $maskc) (i64.const 1)) (i64.shr_u (get_local $maskd) (i64.const 63))))
      (set_local $maskd (i64.add (i64.shl (get_local $maskd) (i64.const 1)) (i64.shr_u (get_local $maske) (i64.const 63))))
      (set_local $maske (i64.add (i64.shl (get_local $maske) (i64.const 1)) (i64.shr_u (get_local $maskf) (i64.const 63))))
      (set_local $maskf (i64.add (i64.shl (get_local $maskf) (i64.const 1)) (i64.shr_u (get_local $maskg) (i64.const 63))))
      (set_local $maskg (i64.add (i64.shl (get_local $maskg) (i64.const 1)) (i64.shr_u (get_local $maskh) (i64.const 63))))
      (set_local $maskh (i64.shl (get_local $maskh) (i64.const 1)))
      (br $loop)
    )

    (loop $done $loop
      ;; loop while mask != 0
      (if (call $isZero_512 (get_local $maska) (get_local $maskb) (get_local $maskc) (get_local $maskd) (get_local $maske) (get_local $maskf) (get_local $maskg) (get_local $maskh))
        (br $done)
      )
      ;; if dividend >= divisor
      (if (call $gte_512 
        (get_local $a)  (get_local $b)  (get_local $c)  (get_local $d)  (get_local $e)  (get_local $f)  (get_local $g)  (get_local $h)
        (get_local $a1) (get_local $b1) (get_local $c1) (get_local $d1) (get_local $e1) (get_local $f1) (get_local $g1) (get_local $h1))
        (then
          ;; dividend = dividend - divisor
          (set_local $carry (i64.lt_u (get_local $h) (get_local $h1)))
          (set_local $h     (i64.sub  (get_local $h) (get_local $h1)))

          (set_local $temp  (i64.sub  (get_local $g) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $g)))
          (set_local $g     (i64.sub  (get_local $temp) (get_local $g1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $g) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $f) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $f)))
          (set_local $f     (i64.sub  (get_local $temp) (get_local $f1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $f) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $e) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $e)))
          (set_local $e     (i64.sub  (get_local $temp) (get_local $e1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $e) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $d) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $d)))
          (set_local $d     (i64.sub  (get_local $temp) (get_local $d1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $d) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $c) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $c)))
          (set_local $c     (i64.sub  (get_local $temp) (get_local $c1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $c) (get_local $temp)) (get_local $carry)))

          (set_local $temp  (i64.sub  (get_local $b) (i64.extend_u/i32 (get_local $carry))))
          (set_local $carry (i64.gt_u (get_local $temp) (get_local $b)))
          (set_local $b     (i64.sub  (get_local $temp) (get_local $b1)))
          (set_local $carry (i32.or   (i64.gt_u (get_local $b) (get_local $temp)) (get_local $carry)))
          (set_local $a     (i64.sub  (i64.sub (get_local $a) (i64.extend_u/i32 (get_local $carry))) (get_local $a1)))
        )
      )
      ;; divisor = divisor >> 1
      (set_local $h1 (i64.add (i64.shr_u (get_local $h1) (i64.const 1)) (i64.shl (get_local $g1) (i64.const 63))))
      (set_local $g1 (i64.add (i64.shr_u (get_local $g1) (i64.const 1)) (i64.shl (get_local $f1) (i64.const 63))))
      (set_local $f1 (i64.add (i64.shr_u (get_local $f1) (i64.const 1)) (i64.shl (get_local $e1) (i64.const 63))))
      (set_local $e1 (i64.add (i64.shr_u (get_local $e1) (i64.const 1)) (i64.shl (get_local $d1) (i64.const 63))))
      (set_local $d1 (i64.add (i64.shr_u (get_local $d1) (i64.const 1)) (i64.shl (get_local $c1) (i64.const 63))))
      (set_local $c1 (i64.add (i64.shr_u (get_local $c1) (i64.const 1)) (i64.shl (get_local $b1) (i64.const 63))))
      (set_local $b1 (i64.add (i64.shr_u (get_local $b1) (i64.const 1)) (i64.shl (get_local $a1) (i64.const 63))))
      (set_local $a1 (i64.shr_u (get_local $a1) (i64.const 1)))

      ;; mask = mask >> 1
      (set_local $maskh (i64.add (i64.shr_u (get_local $maskh) (i64.const 1)) (i64.shl (get_local $maskg) (i64.const 63))))
      (set_local $maskg (i64.add (i64.shr_u (get_local $maskg) (i64.const 1)) (i64.shl (get_local $maskf) (i64.const 63))))
      (set_local $maskf (i64.add (i64.shr_u (get_local $maskf) (i64.const 1)) (i64.shl (get_local $maske) (i64.const 63))))
      (set_local $maske (i64.add (i64.shr_u (get_local $maske) (i64.const 1)) (i64.shl (get_local $maskd) (i64.const 63))))
      (set_local $maskd (i64.add (i64.shr_u (get_local $maskd) (i64.const 1)) (i64.shl (get_local $maskc) (i64.const 63))))
      (set_local $maskc (i64.add (i64.shr_u (get_local $maskc) (i64.const 1)) (i64.shl (get_local $maskb) (i64.const 63))))
      (set_local $maskb (i64.add (i64.shr_u (get_local $maskb) (i64.const 1)) (i64.shl (get_local $maska) (i64.const 63))))
      (set_local $maska (i64.shr_u (get_local $maska) (i64.const 1)))
      (br $loop)
    )
  );; end of main

  (i64.store (get_local $sp) (get_local $e))
  (i64.store (i32.sub (get_local $sp) (i32.const 8)) (get_local $f))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (get_local $g))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (get_local $h))
  (get_local $sp)
)

(func $isZero_512
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (param i64)
  (result i32)
  (i64.eqz (i64.or (i64.or (i64.or (i64.or (i64.or (i64.or (i64.or (get_local 0) (get_local 1)) (get_local 2)) (get_local 3)) (get_local 4)) (get_local 5)) (get_local 6)) (get_local 7)))
)

(func $gte_512
  (param $a0 i64)
  (param $a1 i64)
  (param $a2 i64)
  (param $a3 i64)
  (param $a4 i64)
  (param $a5 i64)
  (param $a6 i64)
  (param $a7 i64)

  (param $b0 i64)
  (param $b1 i64)
  (param $b2 i64)
  (param $b3 i64)
  (param $b4 i64)
  (param $b5 i64)
  (param $b6 i64)
  (param $b7 i64)

  (result i32)

  ;; a0 > b0 || (a0 == b0 && (a1 > b1 || (a1 == b1 && (a2 > b2 || (a2 == b2 && a3 >= b3 ) ))))
  (i32.or  (i64.gt_u (get_local $a0) (get_local $b0)) ;; a0 > b0
  (i32.and (i64.eq   (get_local $a0) (get_local $b0))
  (i32.or  (i64.gt_u (get_local $a1) (get_local $b1)) ;; a1 > b1
  (i32.and (i64.eq   (get_local $a1) (get_local $b1)) ;; a1 == b1
  (i32.or  (i64.gt_u (get_local $a2) (get_local $b2)) ;; a2 > b2
  (i32.and (i64.eq   (get_local $a2) (get_local $b2))
  (i32.or  (i64.gt_u (get_local $a3) (get_local $b3)) ;; a3 > b3
  (i32.and (i64.eq   (get_local $a3) (get_local $b3))
  (i32.or  (i64.gt_u (get_local $a4) (get_local $b4)) ;; a4 > b4
  (i32.and (i64.eq   (get_local $a4) (get_local $b4))
  (i32.or  (i64.gt_u (get_local $a5) (get_local $b5)) ;; a5 > b5
  (i32.and (i64.eq   (get_local $a5) (get_local $b5))
  (i32.or  (i64.gt_u (get_local $a6) (get_local $b6)) ;; a6 > b6
  (i32.and (i64.eq   (get_local $a6) (get_local $b6))
           (i64.ge_u (get_local $a7) (get_local $b7)))))))))))))))))
