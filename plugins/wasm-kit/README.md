# wasm-kit

WebAssembly bar for the dark factory Cursor lane. Public research pilot: WebAssembly/spec (Apache-2.0 interpreter + core tests) plus MIT-capable wat/wasm tooling (bytecodealliance/wasm-tools Apache-2.0/MIT dual; zksecurity/wasmati MIT corroboration).

| Surface | Path |
|---------|------|
| Skills | `skills/wasm`, `skills/poteto-wasm` |
| Rule | `rules/wasm.mdc` (`**/*.{wat,wast,wasm,toml,yml,yaml}`, not alwaysApply) |
| Tier 0 | `scripts/wasm-rg-gate.sh` (wat hygiene leftover debug; unbounded memory.grow without `;;`; host eval imports; **single-walk**; requires **rg** + PCRE `-P`) |
| Tier 0.5 | `scripts/wasm-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `WASM_RG_BUDGET_MS`) |
| Tier 1 | `scripts/wasm-tools-gate.sh` (wat/wasm tooling Makefile / Cargo / package.json / CI wiring) |
| Selfcheck | `scripts/wasm-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/wasm-gates.yml` |
| Boundaries | `templates/no_debug_wat.wat`, `templates/bounded_memory_grow.wat`, `templates/no_host_eval_import.wat` |

PSR Wasm encode (Programming Standards Reference): no leftover debug `call $print/$log/$debug` or `(import "console" "log"`; no `memory.grow` without same-line `;;` bound comment; no imported host eval patterns (`eval` / `eval_js` / `Function` / `exec` / `js_eval`). Primary authority: portable trust bar for Wasm product trees. Toolchain: **wat2wasm** / **wasm-tools** / **wabt** wiring required at 0.1.0.

Compose with `/poteto-mode`. Tier 1 tools gate checks wiring (config-only at 0.1.0).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/wasm-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-wasm` (Wasm stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`wasm-rg-gate` walks the tree **once** (union of line smells), classifies the hit set in parallel. `wasm-hotpath-gate` fails if that wall exceeds `WASM_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `wasm-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_debug_wat.wat` / `templates/bounded_memory_grow.wat` / `templates/no_host_eval_import.wat` over scattered allows.

## Selfcheck

`bash scripts/wasm-kit-selfcheck.sh` proves rg/hotpath/tools gates discriminate fixtures, single-walk encode, budget discrimination (`WASM_RG_BUDGET_MS=1`), tooling wiring bar, and template presence.
