;; signed less than
(func $SSTORE
  (param $sp i32)
  (result i32)
  ;; pop two items off the stack
  (set_local $sp (i32.sub (get_local $sp) (i32.const 64))) 
  (call_import $sstore (i32.add (get_local $sp) (i32.const 40))  (i32.add (get_local $sp) (i32.const 8)))
  (return (get_local $sp)))
