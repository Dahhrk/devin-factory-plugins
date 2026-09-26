---
name: poteto-vite
description: Poteto-mode bar for Vite products. Use for /poteto-mode on Vite work, or when Dark asks for poteto bar on Vite. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Vite

Apply `/poteto-mode` non-negotiables, then this leaf for Vite apps / libraries (`vite.config.*`).

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/vite-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/vite-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `VITE_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/vite-vite-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious server / monorepo / legacy constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If fs.strict / fs.allow / loadEnv touched: keep strict, workspace allow, VITE_ prefix, or `vite-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `vite build` + preview smoke) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- vite wiring stays on
- Public build / preview contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (fs.allow / loadEnv / define secrets) before micro-opts
2. Delete dead path before adding
3. Default VITE_ prefix before empty-prefix loadEnv
4. workspace-root allow before parent `..`
5. Keep fs.strict true before false
6. Measure (`vite build` / preview) before further micro-opt

Load skill **vite** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Keep Vite fs.strict true`, `Ban loadEnv empty prefix in vite.config`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Vite only)

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
| PSR Vite alignment | checklist: vite wiring, no unchecked fs.strict:false / allow:['..'] / loadEnv empty-prefix |
| CI green | `vite-rg-gate` + `vite-hotpath-gate` + `vite-vite-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).
