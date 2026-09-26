# c-kit

C bar for the dark factory Cursor lane. Public research pilot: libuv/libuv (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/c`, `skills/poteto-c` |
| Rule | `rules/c.mdc` (`**/*.{c,h}`, not alwaysApply) |
| Tier 0 | `scripts/c-rg-gate.sh` (strcpy / strcat / sprintf / gets; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/c-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `C_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/c-fmt-gate.sh` + `scripts/c-warn-gate.sh` |
| Tier 1 | `scripts/c-san-ci-gate.sh` (ASAN/UBSAN/TSAN or `-fsanitize=` in CMake/CI) |
| Tier 1b | `scripts/c-malloc-gate.sh` (malloc/calloc/realloc NULL-checked nearby) |
| Selfcheck | `scripts/c-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/c-gates.yml` + `templates/clang-format` |
| Boundaries | `templates/bounded_string.c`, `templates/malloc_check.c` |

PSR C encode (Programming Standards Reference): strong compiler diagnostics; static analysis; ownership conventions; bounds, integer and lifetime checks; sanitizers where supported; explicit handling of undefined behaviour. Language-farm practical bar: clang-format, `-Wall -Wextra`, sanitizers where practical, buffer/unsafe string smells, malloc check. Primary authority: ISO C/WG14, CERT C, applicable MISRA C.

Compose with `/poteto-mode`. Tier 0.5 fmt is live when clang-format exists else `.clang-format`. Warn/san gates check wiring.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/c-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-c` (C stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`c-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `c-hotpath-gate` fails if that wall exceeds `C_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and libuv under default budget.

### Escape

Line marker `c-rg-allow` with a short rationale. Prefer named boundaries from `templates/bounded_string.c` / `templates/malloc_check.c` over scattered allows.

## Selfcheck

`bash scripts/c-kit-selfcheck.sh` proves rg/hotpath/fmt/warn/san/malloc gates discriminate fixtures, single-walk encode, budget discrimination (`C_RG_BUDGET_MS=1`), and template presence.
