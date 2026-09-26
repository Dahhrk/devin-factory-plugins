(module
  (import "env" "write_bytes" (func $write_bytes (param i32 i32)))
  (memory 1 8)
  (func $grow_checked (result i32)
    i32.const 1
    memory.grow ;; grow by 1 page; max 8 pages declared above
  )
  (func $ping
    i32.const 0
    i32.const 0
    call $write_bytes ;; wasm-rg-allow: fixture documents allow marker on typed host seam
  )
  (export "grow_checked" (func $grow_checked))
  (export "ping" (func $ping))
)
