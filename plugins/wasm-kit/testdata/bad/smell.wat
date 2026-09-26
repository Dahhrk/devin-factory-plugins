;; Intentional smells for wasm-rg-gate discrimination (not product code).
(module
  (import "env" "eval" (func $host_eval (param i32)))
  (import "console" "log" (func $clog (param i32)))
  (memory 1)
  (func $boom
    i32.const 0
    call $print
    i32.const 4
    memory.grow
    drop
    i32.const 0
    call $host_eval)
  (func $print (param i32))
)
