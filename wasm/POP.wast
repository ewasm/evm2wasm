(func $POP
  (param $sp i32)
  (result i32)

  ;; FIXME: check stack underflow

  (return (i32.sub (get_local $sp) (i32.const 32)))
)
