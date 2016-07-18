;; signed less than
(func $SSTORE
  (param $sp i32)
  (result i32)
  ;;todo check if 
  (call_import $useGas (i32.const 15000))
  (call_import $sstore (get_local $sp) (i32.sub (get_local $sp) (i32.const 32)))
  ;; pop two items off the stack
  (return (i32.sub (get_local $sp) (i32.const 64)))
)
