;; Named boundary: remove leftover call $print/$log/$debug and console.log imports (PSR Wasm hygiene).
;; Prefer temporary local probes; do not ship debug host calls in product .wat.
;; SPDX-License-Identifier: MIT
(module
  (memory 1)
  (func $add (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add)
  (export "add" (func $add))
)
