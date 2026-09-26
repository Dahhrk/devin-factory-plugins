---
name: poteto-tailwind
description: Poteto-mode bar for Tailwind CSS products. Use for /poteto-mode on Tailwind work, or when Dark asks for poteto bar on Tailwind. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Tailwind

Apply `/poteto-mode` non-negotiables, then this leaf for Tailwind CSS (templates / entry CSS / `tailwind.config.*` / `@source`).

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/tailwind-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/tailwind-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `TAILWIND_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/tailwind-tailwind-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious legacy `@apply` / safelist / content constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If `@apply` / arbitrary value / safelist / `@source inline` / empty content / dynamic class concat touched: utility/token/path fix, or `tailwind-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `tailwindcss` build / size budget / design-token lint) override when present. Prove on the real artifact (CSS build).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- tailwindcss wiring stays on
- Public class / design-token contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (content paths / purge / safelist / input-driven classes) before micro-opts
2. Delete dead path before adding
3. Utilities / components before `@apply`
4. Theme tokens before arbitrary values
5. Correct `content` / `@source` before safelist / `@source inline`
6. Measure (CSS build / bundle size) before further micro-opt

Load skill **tailwind** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban @apply overuse in product CSS`, `Require complete Tailwind content paths`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Tailwind only)

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
| PSR Tailwind alignment | checklist: tailwindcss wiring, no unchecked @apply / arbitrary sprawl / safelist / content-path miss |
| CI green | `tailwind-rg-gate` + `tailwind-hotpath-gate` + `tailwind-tailwind-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Tailwind uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Tailwind passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
