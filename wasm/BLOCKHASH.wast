(import $getBlockHash "ethereum" "getBlockHash" (param i32 i32) )
(func $BLOCKHASH (param $sp i32)
   
  
  (call_import $getBlockHash
(call $check_overflow (i64.load (i32.add (get_local $sp) (i32.const 0)))
                                   (i64.load (i32.add (get_local $sp) (i32.const 8)))
                                   (i64.load (i32.add (get_local $sp) (i32.const 16)))
                                   (i64.load (i32.add (get_local $sp) (i32.const 24))))    (i32.add (get_local $sp) (i32.const 0))))