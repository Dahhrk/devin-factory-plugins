;; Named boundary: typed host imports only; no eval/Function/exec-shaped host names (PSR Wasm).
;; SPDX-License-Identifier: MIT
(module
  (import "env" "write_bytes" (func $write_bytes (param i32 i32)))
  (memory 1)
  (func $ping
    i32.const 0
    i32.const 0
    call $write_bytes)
  (export "ping" (func $ping))
)
