
(module
  (import "ethereum" "useGas" (func $useGas (param i64)))
  (global $cb_dest (mut i32) (i32.const 0))
  (global $sp (mut i32) (i32.const -32))
  (global $init (mut i32) (i32.const 0))

  ;; memory related global
  (global $memstart i32  (i32.const 33832))
  ;; the number of 256 words stored in memory
  (global $wordCount (mut i64) (i64.const 0))
  ;; what was charged for the last memory allocation
  (global $prevMemCost (mut i64) (i64.const 0))

  ;; TODO: memory should only be 1, but can't resize right now
  (memory 500)
  (export "memory" (memory 0))

  

  
  (func $main
    (export "main")
    (local $jump_dest i32)
    (set_local $jump_dest (i32.const -1))

    (block $done
      (loop $loop
        
  (block $0 
    (if
      (i32.eqz (get_global $init))
      (then
        (set_global $init (i32.const 1))
        (br $0))
      (else
        ;; the callback dest can never be in the first block
        (if (i32.eq (get_global $cb_dest) (i32.const 0)) 
          (then
            (unreachable)
          )
          (else 
            ;; return callback destination and zero out $cb_dest 
            get_global $cb_dest
            (set_global $cb_dest (i32.const 0))
            (br_table $0 )
          )))))(call $useGas (i64.const 0)) )))
)