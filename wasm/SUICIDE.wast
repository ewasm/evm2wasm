(import $selfDestruct "ethereum" "selfDestruct" (param i32))
(func $SUICIDE
  (param $sp i32)      
  (call_import $selfDestruct (get_local $sp)))
