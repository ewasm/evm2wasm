(func $MULMOD
  (local $sp i32)

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
  (set_local $a (i64.load (i32.add (get_global $sp) (i32.const 24))))
  (set_local $c (i64.load (i32.add (get_global $sp) (i32.const 16))))
  (set_local $e (i64.load (i32.add (get_global $sp) (i32.const  8))))
  (set_local $g (i64.load          (get_global $sp)))
  (set_local $i (i64.load (i32.sub (get_global $sp) (i32.const  8))))
  (set_local $k (i64.load (i32.sub (get_global $sp) (i32.const 16))))
  (set_local $m (i64.load (i32.sub (get_global $sp) (i32.const 24))))
  (set_local $o (i64.load (i32.sub (get_global $sp) (i32.const 32))))

  (set_local $sp (i32.sub (get_global $sp) (i32.const 64)))

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
  ;; o * h + $temp1 
  (set_local $temp1 (i64.add (i64.mul (get_local $o) (get_local $h)) (i64.and (get_local $temp1) (i64.const 4294967295))))
  ;; o * g + $temp2 + carry
  (set_local $temp2 (i64.add (i64.add (i64.mul (get_local $o) (get_local $g)) (i64.and (get_local $temp2) (i64.const 4294967295))) (i64.shr_u (get_local $temp1) (i64.const 32))))
  ;; o * f + $temp3 + carry
  (set_local $temp3 (i64.add (i64.add (i64.mul (get_local $o) (get_local $f)) (i64.and (get_local $temp3) (i64.const 4294967295))) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; o * e + $temp4 + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $o) (get_local $e)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; o * d + $temp5 + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $o) (get_local $d)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; o * c + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $o) (get_local $c)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; o * b + $temp7 + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $o) (get_local $b)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; o * a + carry + rowCarry
  (set_local $p (i64.add (i64.add (i64.mul (get_local $o) (get_local $a)) (i64.shr_u (get_local $temp7) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $p) (i64.const 32)))

  ;; third row - n
  ;; n * h + $temp2 
  (set_local $temp2 (i64.add (i64.mul (get_local $n) (get_local $h)) (i64.and (get_local $temp2) (i64.const 4294967295))))
  ;; n * g + $temp3  carry
  (set_local $temp3 (i64.add (i64.add (i64.mul (get_local $n) (get_local $g)) (i64.and (get_local $temp3) (i64.const 4294967295))) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; n * f + $temp4) + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $n) (get_local $f)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; n * e + $temp5 + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $n) (get_local $e)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; n * d + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $n) (get_local $d)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; n * c + $temp7 + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $n) (get_local $c)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; n * b + $p + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $n) (get_local $b)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; n * a + carry
  (set_local $o (i64.add (i64.add (i64.mul (get_local $n) (get_local $a)) (i64.shr_u (get_local $p) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $o) (i64.const 32)))

  ;; forth row 
  ;; m * h + $temp3
  (set_local $temp3 (i64.add (i64.mul (get_local $m) (get_local $h)) (i64.and (get_local $temp3) (i64.const 4294967295))))
  ;; m * g + $temp4 + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $m) (get_local $g)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; m * f + $temp5 + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $m) (get_local $f)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; m * e + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $m) (get_local $e)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; m * d + $temp7 + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $m) (get_local $d)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; m * c + $p + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $m) (get_local $c)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; m * b + $o + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $m) (get_local $b)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; m * a + carry + rowCarry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $m) (get_local $a)) (i64.shr_u (get_local $o) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $n) (i64.const 32)))

  ;; fith row
  ;; l * h + $temp4
  (set_local $temp4 (i64.add (i64.mul (get_local $l) (get_local $h)) (i64.and (get_local $temp4) (i64.const 4294967295))))
  ;; l * g + $temp5 + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $l) (get_local $g)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; l * f + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $l) (get_local $f)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; l * e + $temp7 + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $l) (get_local $e)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; l * d + $p + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $l) (get_local $d)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; l * c + $o + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $l) (get_local $c)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; l * b + $n + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $l) (get_local $b)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; l * a + carry + rowCarry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $l) (get_local $a)) (i64.shr_u (get_local $n) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $m) (i64.const 32)))

  ;; sixth row 
  ;; k * h + $temp5
  (set_local $temp5 (i64.add (i64.mul (get_local $k) (get_local $h)) (i64.and (get_local $temp5) (i64.const 4294967295))))
  ;; k * g + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $k) (get_local $g)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; k * f + $temp7 + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $k) (get_local $f)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; k * e + $p + carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $k) (get_local $e)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; k * d + $o + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $k) (get_local $d)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; k * c + $n + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $k) (get_local $c)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; k * b + $m + carry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $k) (get_local $b)) (i64.and (get_local $m)     (i64.const 4294967295))) (i64.shr_u (get_local $n)     (i64.const 32))))
  ;; k * a + carry
  (set_local $l     (i64.add (i64.add (i64.mul (get_local $k) (get_local $a)) (i64.shr_u (get_local $m) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $l) (i64.const 32)))

  ;; seventh row
  ;; j * h + $temp6
  (set_local $temp6 (i64.add (i64.mul (get_local $j) (get_local $h)) (i64.and (get_local $temp6) (i64.const 4294967295))))
  ;; j * g + $temp7 + carry
  (set_local $temp7 (i64.add (i64.add (i64.mul (get_local $j) (get_local $g)) (i64.and (get_local $temp7) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; j * f + $p +carry
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $j) (get_local $f)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; j * e + $o + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $j) (get_local $e)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; j * d + $n + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $j) (get_local $d)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; j * c + $m + carry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $j) (get_local $c)) (i64.and (get_local $m)     (i64.const 4294967295))) (i64.shr_u (get_local $n)     (i64.const 32))))
  ;; j * b + $l + carry
  (set_local $l     (i64.add (i64.add (i64.mul (get_local $j) (get_local $b)) (i64.and (get_local $l)     (i64.const 4294967295))) (i64.shr_u (get_local $m)     (i64.const 32))))
  ;; j * a + carry
  (set_local $k     (i64.add (i64.add (i64.mul (get_local $j) (get_local $a)) (i64.shr_u (get_local $l) (i64.const 32))) (get_local $rowCarry)))
  (set_local $rowCarry (i64.shr_u (get_local $k) (i64.const 32)))

  ;; eigth row
  ;; i * h + $temp7 
  (set_local $temp7 (i64.add (i64.mul (get_local $i) (get_local $h)) (i64.and (get_local $temp7) (i64.const 4294967295))))
  ;; i * g + $p 
  (set_local $p     (i64.add (i64.add (i64.mul (get_local $i) (get_local $g)) (i64.and (get_local $p)     (i64.const 4294967295))) (i64.shr_u (get_local $temp7) (i64.const 32))))
  ;; i * f + $o + carry
  (set_local $o     (i64.add (i64.add (i64.mul (get_local $i) (get_local $f)) (i64.and (get_local $o)     (i64.const 4294967295))) (i64.shr_u (get_local $p)     (i64.const 32))))
  ;; i * e + $n + carry
  (set_local $n     (i64.add (i64.add (i64.mul (get_local $i) (get_local $e)) (i64.and (get_local $n)     (i64.const 4294967295))) (i64.shr_u (get_local $o)     (i64.const 32))))
  ;; i * d + $m + carry
  (set_local $m     (i64.add (i64.add (i64.mul (get_local $i) (get_local $d)) (i64.and (get_local $m)     (i64.const 4294967295))) (i64.shr_u (get_local $n)     (i64.const 32))))
  ;; i * c + $l + carry
  (set_local $l     (i64.add (i64.add (i64.mul (get_local $i) (get_local $c)) (i64.and (get_local $l)     (i64.const 4294967295))) (i64.shr_u (get_local $m)     (i64.const 32))))
  ;; i * b + $k + carry
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

  (call $mod_512
         (get_local $a) (get_local $b) (get_local $c) (get_local $d) (get_local $e) (get_local $f) (get_local $g) (get_local $h) 
         (i64.const 0)  (i64.const 0) (i64.const 0)  (i64.const 0)  (get_local $moda) (get_local $modb) (get_local $modc) (get_local $modd) (i32.add (get_local $sp) (i32.const 24))
  )
)
