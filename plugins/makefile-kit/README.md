# makefile-kit

Makefile bar for the dark factory Cursor lane. Public research pilot: mirror/make (GPL-3.0) GNU Make reference (`Phony Targets`, `Include`, `One Shell`, `Recursion`, `Shell Function` in `doc/make.texi`).

| Surface | Path |
|---------|------|
| Skills | `skills/makefile`, `skills/poteto-makefile` |
| Rule | `rules/makefile.mdc` (`**/Makefile`, `**/makefile`, `**/GNUmakefile`, `**/*.mk`, `**/*.make`, not alwaysApply) |
| Tier 0 | `scripts/makefile-rg-gate.sh` (recursive make without .PHONY; tab/space mix; unchecked $(shell); include of untrusted path; .ONESHELL / curl\|bash; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/makefile-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `MAKEFILE_RG_BUDGET_MS`) |
| Tier 1 | `scripts/makefile-make-gate.sh` (Makefile / *.mk / CI make wiring / live `make --version` when resolvable) |
| Selfcheck | `scripts/makefile-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/makefile-gates.yml` |
| Boundaries | `templates/phony_recursive.mk`, `templates/tab_recipes.mk`, `templates/no_unchecked_shell.mk`, `templates/trusted_static_include.mk`, `templates/no_oneshell_curl_bash.mk` |

PSR Makefile encode (Programming Standards Reference): declare `.PHONY` for recursive `$(MAKE)` targets; recipe lines use real tabs (never space-indented recipes); avoid unchecked `$(shell ...)` (prefer make natives / check `.SHELLSTATUS`); never `include $(untrusted)` / `-include ${...}` of variable paths (prefer static `include rules.mk` or vetted `$(CURDIR)` / `$(srcdir)`); never `.ONESHELL` abuse or `curl|bash` / `wget|sh` recipes. Primary authority: GNU Make manual (`doc/make.texi`) via mirror/make — GPL-3.0.

Compose with `/poteto-mode`. Tier 1 checks make wiring (live `make --version` when resolvable unless `MAKEFILE_MAKE_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/makefile-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-makefile` (Makefile / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`makefile-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `makefile-hotpath-gate` fails if that wall exceeds `MAKEFILE_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `makefile-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer `.PHONY` for recursive targets. Prefer tab-indented recipes. Prefer make natives over `$(shell)`. Prefer static `include`. Prefer no `.ONESHELL` / no pipe-to-shell.

## Selfcheck

`bash scripts/makefile-kit-selfcheck.sh` proves rg/hotpath/make gates discriminate fixtures, single-walk encode, budget discrimination (`MAKEFILE_RG_BUDGET_MS=1`), make wiring bar, and template presence.
