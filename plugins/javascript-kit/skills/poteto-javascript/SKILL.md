---
name: poteto-javascript
description: Poteto-mode bar for JavaScript products (distinct from TypeScript). Use for /poteto-mode on JS work, or when Dark asks for poteto bar on JavaScript. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto JavaScript

Apply `/poteto-mode` non-negotiables, then this leaf for Node / browser JS libraries / services / CLIs that are **not** TypeScript.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/js-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/js-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `JS_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/js-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/js-eslint-flat-gate.sh <product-root>` exits 0.
5. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious async / security / prototype constraints.
6. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
7. If eval / prototype-pollution / sync-fs touched: parsers / null-prototype merge / `fs.promises`, `js-rg-allow` on the smell line when intentional.
8. Stricter product gates (live prettier, eslint) override when present. Prove on the real artifact (tests / eslint / prettier).
9. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.
10. Do not route plain JS through typescript-kit oxlint / tsconfig bar.

## Keep (default)

- Prettier / ESLint flat wiring stay on
- Public API unchanged unless the goal is an API break
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (eval / prototype / sync fs / input) before micro-opts
2. Delete dead path before adding
3. Async fs before sync fs on request path
4. Null-prototype merge before Object.assign onto untrusted input
5. Measure (tests / eslint / prettier) before further micro-opt

Load skill **javascript** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace readFileSync with fs.promises`, `Add eslint flat config`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (JavaScript only)

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
| PSR JS alignment | checklist: Prettier, ESLint flat config, no unchecked eval / prototype-pollution / sync-fs |
| CI green | `js-rg-gate` + `js-hotpath-gate` + `js-fmt-gate` + `js-eslint-flat-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. JavaScript uses this sheet. TypeScript uses typescript-kit. Kitchen docs stay docs-only. No Control-Glass on language-farm JS passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
