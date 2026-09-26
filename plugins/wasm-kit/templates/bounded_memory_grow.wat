;; Named boundary: every memory.grow documents its bound / intent on the same line (PSR Wasm).
;; SPDX-License-Identifier: MIT
(module
  (memory 1 16)
  (func $grow_one (result i32)
    i32.const 1
    memory.grow ;; grow by 1 page; max 16 pages declared above
  )
  (export "grow_one" (func $grow_one))
)
