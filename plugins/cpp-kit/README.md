# cpp-kit

C++ bar for the dark factory Cursor lane. Public research pilot: fmtlib/fmt (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/cpp`, `skills/poteto-cpp` |
| Rule | `rules/cpp.mdc` (`**/*.{cpp,cc,cxx,hpp,hh,h}`, not alwaysApply) |
| Tier 0 | `scripts/cpp-rg-gate.sh` (raw new/delete; C-style casts; sprintf/vsprintf; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/cpp-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `CPP_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/cpp-fmt-gate.sh` + `scripts/cpp-warn-gate.sh` |
| Tier 1 | `scripts/cpp-tidy-ci-gate.sh` (`.clang-tidy` or `clang-tidy` in CMake/CI) |
| Selfcheck | `scripts/cpp-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/cpp-gates.yml` + `templates/clang-format` + `templates/clang-tidy/clang-tidy` |
| Boundaries | `templates/unique_ptr_new.cpp`, `templates/static_cast.cpp` |

PSR C++ encode (Programming Standards Reference): clang-format; strong compiler diagnostics (`-Wall -Wextra`); clang-tidy where practical; prefer `unique_ptr` / `make_unique` over raw `new`/`delete`; prefer `static_cast` / `reinterpret_cast` / `const_cast` over C-style casts; no `sprintf` / `vsprintf`. Primary authority: ISO C++ / WG21, C++ Core Guidelines, CERT C++.

Compose with `/poteto-mode`. Tier 0.5 fmt is live when clang-format exists else `.clang-format`. Warn/tidy gates check wiring.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/cpp-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-cpp` (C++ stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`cpp-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `cpp-hotpath-gate` fails if that wall exceeds `CPP_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and fmt under default budget.

### Escape

Line marker `cpp-rg-allow` with a short rationale. Prefer named boundaries from `templates/unique_ptr_new.cpp` / `templates/static_cast.cpp` over scattered allows.

## Selfcheck

`bash scripts/cpp-kit-selfcheck.sh` proves rg/hotpath/fmt/warn/tidy gates discriminate fixtures, single-walk encode, budget discrimination (`CPP_RG_BUDGET_MS=1`), and template presence.
