# r-kit

R bar for the dark factory Cursor lane. Public research pilot: tidyverse/ggplot2 (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/r`, `skills/poteto-r` |
| Rule | `rules/r.mdc` (`**/*.{R,r,Rmd,rmd}`, not alwaysApply) |
| Tier 0 | `scripts/r-rg-gate.sh` (`attach()`; `T`/`F` symbols; `eval(parse())`; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/r-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `R_RG_BUDGET_MS`) |
| Tier 1 | `scripts/r-lintr-gate.sh` (lintr wiring / live; requires `T_and_F_symbol_linter` + `undesirable_function_linter`) |
| Selfcheck | `scripts/r-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/r-gates.yml` |
| Boundaries | `templates/no_attach.R`, `templates/true_false_not_tf.R`, `templates/no_eval_parse.R` |
| Lint starter | `templates/.lintr` |

PSR R encode (Programming Standards Reference): lintr lint; no `attach()` without allow; `TRUE`/`FALSE` not `T`/`F` without allow; no `eval(parse())` without allow. Primary authority: lintr (`T_and_F_symbol_linter`, `undesirable_function_linter` for `attach`) and dynamic-eval trust bar.

Compose with `/poteto-mode`. Tier 1 lintr checks wiring (live `lintr::lint_dir` when R + lintr on PATH unless `R_LINTR_CONFIG_ONLY=1`). Config must keep `T_and_F_symbol_linter` and `undesirable_function_linter` enabled (not nulled).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/r-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-r` (R stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`r-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `r-hotpath-gate` fails if that wall exceeds `R_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and ggplot2 `R/` under default budget.

### Escape

Line marker `r-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_attach.R` / `templates/true_false_not_tf.R` / `templates/no_eval_parse.R` over scattered allows.

## Selfcheck

`bash scripts/r-kit-selfcheck.sh` proves rg/hotpath/lintr gates discriminate fixtures, single-walk encode, budget discrimination (`R_RG_BUDGET_MS=1`), PSR lintr rules bar, and template presence.
