---
name: r
description: R PSR bar. lintr lint, no attach(), TRUE/FALSE not T/F, no eval(parse()). Use when reading or editing any .R/.r/.Rmd in a factory product.
paths: ["**/*.R", "**/*.r", "**/*.Rmd", "**/*.rmd", "**/.lintr", "**/.github/workflows/**"]
---

# R

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference R checks into product gates.

## PSR R (encoded)

1. **Agreed linter** — `lintr` (`.lintr` / CI `lintr::lint` / `lintr::lint_dir` / `lintr::lint_package` / live). Gate: `scripts/r-lintr-gate.sh`. Product CI: `templates/github-workflows/r-gates.yml`. Config must keep **T_and_F_symbol_linter** and **undesirable_function_linter** enabled (not nulled).
2. **attach()** — no `attach(` without allow. Prefer `pkg::fun` / explicit env / `@importFrom`. Gate: `scripts/r-rg-gate.sh` (single-walk). Template: `templates/no_attach.R`.
3. **T/F vs TRUE/FALSE** — no symbol `T` / `F` without allow. Prefer `TRUE` / `FALSE`. Gate: `scripts/r-rg-gate.sh`. Template: `templates/true_false_not_tf.R`.
4. **eval(parse())** — no `eval(parse(...))` without allow. Prefer `get` / `[[` / explicit maps / `rlang`. Gate: `scripts/r-rg-gate.sh`. Template: `templates/no_eval_parse.R`.
5. **Hot-path** — `scripts/r-hotpath-gate.sh` fails if rg-gate wall exceeds `R_RG_BUDGET_MS` (default 250ms).

## Rules

- `r-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-r**.
