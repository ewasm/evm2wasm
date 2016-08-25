(func $CALLDATACOPY
  (param $sp i32)
  (result i32)
  (local $memstart i32)

  (set_local $memstart (i32.const 33832))
  (i32.load (i32.sub (get_local $sp) (i32.const 64)))

  (call_import $callDataCopy 
              (i32.add  (i32.load (get_local $sp)) (get_local $memstart))
              (i32.load (i32.sub (get_local $sp) (i32.const 32)))
              (i32.load (i32.sub (get_local $sp) (i32.const 64))))

  ;; pop 3 stack items
  (return (i32.sub (get_local $sp) (i32.const 96)))
)

