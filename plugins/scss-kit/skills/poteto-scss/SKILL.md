---
name: poteto-scss
description: Poteto-mode bar for SCSS/Sass products. Use for /poteto-mode on SCSS/Sass work, or when Dark asks for poteto bar on SCSS. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto SCSS

Apply `/poteto-mode` non-negotiables, then this leaf for stylesheets / design-token SCSS / component Sass packs (`.scss` and `.sass`).

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/scss-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/scss-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `SCSS_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/scss-sass-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious cascade / a11y / legacy constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If !important / @extend /deep/>>> / nesting touched: mixin / flat BEM / `:deep()` / modern cascade, or `scss-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `sass` compile with full stylelint-scss) override when present. Prove on the real artifact (visual / layout checks).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- sass / dart-sass wiring stays on
- Public stylesheet / token contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (!important / @extend /deep/>>> / deep nesting / input) before micro-opts
2. Delete dead path before adding
3. Mixin / specificity / `@layer` before `!important` or `@extend`
4. Flat BEM before nesting depth >4
5. `:deep()` / native nesting before `/deep/` / `>>>`
6. Measure (visual / layout / `sass` compile) before further micro-opt

Load skill **scss** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban @extend in product SCSS`, `Wire dart-sass compile in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (SCSS only)

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
| PSR SCSS alignment | checklist: sass/dart-sass wiring, no unchecked !important / @extend /deep/>>> / nesting >4 |
| CI green | `scss-rg-gate` + `scss-hotpath-gate` + `scss-sass-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. SCSS uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm SCSS passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
