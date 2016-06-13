(module 
  (import $blockHash "blockHash"  "ethereum" (param i32) (param i32))
  (func $main
    (local $stackpoint i32)
    (local $pc i32)
    (local $jump_stm i32)
    (loop $exit $cont
      (block
        (block
          (block $a
            (br_table $a 1 2 3 $cont
              (if (i32.eqget_local $jump_stm))
              (get_local $jump_stm)
            )
            ;; first section
          )
          ;; second section
        )
        ;; third section
      )
      ;; jump table
      ;; sets $jump_stm
      (if 
        (then)
        (else
          (if
            (then)
            (else)
          )
        )
      )
    )
  )
)
