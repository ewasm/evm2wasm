(import $getBlockDifficulty "ethereum" "getBlockDifficulty" (param i32))
(func $DIFFICULTY
  (param $sp i32)

  (set_local $sp (i32.add (get_local $sp) (i32.const 32)))
  (call_import $getBlockDifficulty (get_local $sp))
   ;;TODO zero out the rest of the stack
)
