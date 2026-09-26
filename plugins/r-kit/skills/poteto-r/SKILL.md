---
name: poteto-r
description: Poteto-mode bar for R products. Use for /poteto-mode on R work, or when Dark asks for poteto bar on R. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto R

Apply `/poteto-mode` non-negotiables, then this leaf for packages / scripts / analysis packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/r-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/r-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `R_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/r-lintr-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious S3/S4/Rcpp / CRAN constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If attach / T/F / eval(parse) touched: `pkg::fun` / TRUE/FALSE / get-or-map, or `r-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `lintr::lint_package` with full linter set / testthat) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- lintr wiring stays on with T_and_F_symbol_linter and undesirable_function_linter enabled
- Public package / script contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (attach / T/F / eval(parse) / input) before micro-opts
2. Delete dead path before adding
3. `pkg::fun` / `@importFrom` before `attach()`
4. `TRUE` / `FALSE` before symbol `T` / `F`
5. `get` / `[[` / explicit map before `eval(parse())`
6. Measure (testthat / integration) before further micro-opt

Load skill **r** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban attach in product scripts`, `Wire lintr T_and_F_symbol_linter in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (R only)

Weighted product run sheet. Score each dim 0-10, then overall = sum(weight * score).

| Dimension | Weight |
|-----------|--------|
| 1. EXIT catch | 25% |
| 2. AI-slop | 10% |
| 3. Hot-path / perf | 15% |
| 4. Net / API trust | 15% |
| 5. Pack encode | 10% |
| 6. Residual | 5% |
| 7. Code amount | 10% |
| 8. Code quality | 5% |
| 9. Optimisations | 5% |

Standing extras (list separately; do not fold into the 100% weighted overall unless the run asks):

| Extra | /10 | Prove |
|-------|-----|-------|
| PSR R alignment | checklist: lintr lint, T_and_F_symbol_linter, undesirable_function_linter (attach), no unchecked attach / T/F / eval(parse) |
| CI green | `r-rg-gate` + `r-hotpath-gate` + `r-lintr-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. R uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm R passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
