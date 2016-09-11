(func $mul_256
  ;;  a b c d e f g h
  ;;* i j k l m n o p
  ;;----------------
  (param $a i64)
  (param $c i64)
  (param $e i64)
  (param $g i64)

  (param $i i64)
  (param $k i64)
  (param $m i64)
  (param $o i64)

  (param $sp i32)

  (local $b i64)
  (local $d i64)
  (local $f i64)
  (local $h i64)
  (local $j i64)
  (local $l i64)
  (local $n i64)
  (local $p i64)
  (local $temp6 i64)
  (local $temp5 i64)
  (local $temp4 i64)
  (local $temp3 i64)
  (local $temp2 i64)
  (local $temp1 i64)
  (local $temp0 i64)

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
  (set_local $temp5  (i64.add (i64.mul (get_local $p) (get_local $c)) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; p * b + carry
  (set_local $temp6  (i64.add (i64.mul (get_local $p) (get_local $b)) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; p * a + carry
  (set_local $a  (i64.add (i64.mul (get_local $p) (get_local $a)) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; second row
  ;; o * h + $temp1 "pg"
  (set_local $temp1 (i64.add (i64.mul (get_local $o) (get_local $h)) (i64.and (get_local $temp1) (i64.const 4294967295))))
  ;; o * g + $temp2 "pf" + carry
  (set_local $temp2 (i64.add (i64.add (i64.mul (get_local $o) (get_local $g)) (i64.and (get_local $temp2) (i64.const 4294967295))) (i64.shr_u (get_local $temp1) (i64.const 32))))
  ;; o * f + $temp3 "pe" + carry
  (set_local $temp3 (i64.add (i64.add (i64.mul (get_local $o) (get_local $f)) (i64.and (get_local $temp3) (i64.const 4294967295))) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; o * e + $temp4  + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $o) (get_local $e)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; o * d + $temp5  + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $o) (get_local $d)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; o * c + $temp6  + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $o) (get_local $c)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; o * b + $a  + carry
  (set_local $a (i64.add (i64.add (i64.mul (get_local $o) (get_local $b)) (i64.and (get_local $a) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))
  ;; third row - n
  ;; n * h + $temp2 
  (set_local $temp2 (i64.add (i64.mul (get_local $n) (get_local $h)) (i64.and (get_local $temp2) (i64.const 4294967295))))
  ;; n * g + $temp3 + carry
  (set_local $temp3 (i64.add (i64.add (i64.mul (get_local $n) (get_local $g)) (i64.and (get_local $temp3) (i64.const 4294967295))) (i64.shr_u (get_local $temp2) (i64.const 32))))
  ;; n * f + $temp4 + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $n) (get_local $f)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; n * e + $temp5  + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $n) (get_local $e)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; n * d + $temp6  + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $n) (get_local $d)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; n * c + $a  + carry
  (set_local $a (i64.add (i64.add (i64.mul (get_local $n) (get_local $c)) (i64.and (get_local $a) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))

  ;; forth row 
  ;; m * h + $temp3
  (set_local $temp3 (i64.add (i64.mul (get_local $m) (get_local $h)) (i64.and (get_local $temp3) (i64.const 4294967295))))
  ;; m * g + $temp4 + carry
  (set_local $temp4 (i64.add (i64.add (i64.mul (get_local $m) (get_local $g)) (i64.and (get_local $temp4) (i64.const 4294967295))) (i64.shr_u (get_local $temp3) (i64.const 32))))
  ;; m * f + $temp5 + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $m) (get_local $f)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; m * e + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $m) (get_local $e)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; m * d + $a + carry
  (set_local $a (i64.add (i64.add (i64.mul (get_local $m) (get_local $d)) (i64.and (get_local $a) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))

  ;; fith row
  ;; l * h + $temp4
  (set_local $temp4 (i64.add (i64.mul (get_local $l) (get_local $h)) (i64.and (get_local $temp4) (i64.const 4294967295))))
  ;; l * g + $temp5 + carry
  (set_local $temp5 (i64.add (i64.add (i64.mul (get_local $l) (get_local $g)) (i64.and (get_local $temp5) (i64.const 4294967295))) (i64.shr_u (get_local $temp4) (i64.const 32))))
  ;; l * f + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $l) (get_local $f)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; l * e + $a + carry
  (set_local $a (i64.add (i64.add (i64.mul (get_local $l) (get_local $e)) (i64.and (get_local $a) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))

  ;; sixth row 
  ;; k * h + $temp5
  (set_local $temp5 (i64.add (i64.mul (get_local $k) (get_local $h)) (i64.and (get_local $temp5) (i64.const 4294967295))))
  ;; k * g + $temp6 + carry
  (set_local $temp6 (i64.add (i64.add (i64.mul (get_local $k) (get_local $g)) (i64.and (get_local $temp6) (i64.const 4294967295))) (i64.shr_u (get_local $temp5) (i64.const 32))))
  ;; k * f + $a + carry
  (set_local $a (i64.add (i64.add (i64.mul (get_local $k) (get_local $f)) (i64.and (get_local $a) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))))

  ;; seventh row
  ;; j * h + $temp6
  (set_local $temp6 (i64.add (i64.mul (get_local $j) (get_local $h)) (i64.and (get_local $temp6) (i64.const 4294967295))))
  ;; j * g + $a + carry

  ;; eigth row
  ;; i * h + $a
  (set_local $a (i64.add (i64.mul (get_local $i) (get_local $h)) (i64.and (i64.add (i64.add (i64.mul (get_local $j) (get_local $g)) (i64.and (get_local $a) (i64.const 4294967295))) (i64.shr_u (get_local $temp6) (i64.const 32))) (i64.const 4294967295))))

  ;; combine terms
  (set_local $a (i64.or (i64.shl (get_local $a) (i64.const 32)) (i64.and (get_local $temp6) (i64.const 4294967295))))
  (set_local $c (i64.or (i64.shl (get_local $temp5) (i64.const 32)) (i64.and (get_local $temp4) (i64.const 4294967295))))
  (set_local $e (i64.or (i64.shl (get_local $temp3) (i64.const 32)) (i64.and (get_local $temp2) (i64.const 4294967295))))
  (set_local $g (i64.or (i64.shl (get_local $temp1) (i64.const 32)) (i64.and (get_local $temp0) (i64.const 4294967295))))

  ;; save stack 
  (i64.store (get_local $sp) (get_local $a))
  (i64.store (i32.sub (get_local $sp) (i32.const 8)) (get_local $c))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (get_local $e))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (get_local $g))
)
