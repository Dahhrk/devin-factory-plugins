---
name: wasm
description: WebAssembly PSR bar. wat hygiene (leftover debug call/import) banned, unbounded memory.grow without comment banned, imported host eval patterns banned, wat/wasm tooling wiring. Use when reading or editing any .wat / .wast / Wasm host wiring in a factory product.
paths: ["**/*.wat", "**/*.wast", "**/*.wasm", "**/Cargo.toml", "**/Makefile", "**/package.json", "**/.github/workflows/**"]
---

# WebAssembly

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Wasm checks into product gates.

## PSR Wasm (encoded)

1. **wat hygiene / leftover debug** — no leftover `(call $print` / `(call $log` / `(call $debug` or `(import "console" "log"` without allow. Prefer remove before merge. Gate: `scripts/wasm-rg-gate.sh` (single-walk). Template: `templates/no_debug_wat.wat`.
2. **unbounded memory.grow** — no `memory.grow` without a same-line `;;` comment documenting the bound / intent (or `wasm-rg-allow`). Gate: `scripts/wasm-rg-gate.sh`. Template: `templates/bounded_memory_grow.wat`.
3. **imported host eval** — no `(import ... "eval"` / `"eval_js"` / `"Function"` / `"exec"` / `"js_eval"` without allow. Prefer typed host APIs with no string-eval surface. Gate: `scripts/wasm-rg-gate.sh`. Template: `templates/no_host_eval_import.wat`.
4. **Hot-path** — `scripts/wasm-hotpath-gate.sh` fails if rg-gate wall exceeds `WASM_RG_BUDGET_MS` (default 250ms).
5. **wat / wasm tooling wiring** — `.wat` / `.wast` / `.wasm` sources plus Makefile / Cargo / package.json / CI mentioning `wat2wasm` / `wasm-tools` / `wabt` / `wasm-as` / `wasm-opt` / `wasmati`. Gate: `scripts/wasm-tools-gate.sh`. Product CI: `templates/github-workflows/wasm-gates.yml`.

## Rules

- `wasm-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-wasm**.
