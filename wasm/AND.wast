;; AND(sp[-1], sp[-2])
(func $AND
  (param $sp i32)
  (result i32)

  (i64.store (i32.sub (get_local $sp) (i32.const 8))  (i64.and (i64.load (i32.sub (get_local $sp) (i32.const 8)))  (i64.load (i32.add (get_local $sp) (i32.const 24)))))
  (i64.store (i32.sub (get_local $sp) (i32.const 16)) (i64.and (i64.load (i32.sub (get_local $sp) (i32.const 16))) (i64.load (i32.add (get_local $sp) (i32.const 16)))))
  (i64.store (i32.sub (get_local $sp) (i32.const 24)) (i64.and (i64.load (i32.sub (get_local $sp) (i32.const 24))) (i64.load (i32.add (get_local $sp) (i32.const 8)))))
  (i64.store (i32.sub (get_local $sp) (i32.const 32)) (i64.and (i64.load (i32.sub (get_local $sp) (i32.const 32))) (i64.load (get_local $sp))))

  (return $sp (i32.sub (get_local $sp) (i32.const 32)))
)
