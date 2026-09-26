---
name: poteto-fortran
description: Poteto-mode bar for Fortran products. Use for /poteto-mode on Fortran work, or when Dark asks for poteto bar on Fortran. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Fortran

Apply `/poteto-mode` non-negotiables, then this leaf for libraries / apps / numerical packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/fortran-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/fortran-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `FORTRAN_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/fortran-fortitude-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious numerical / standard / ABI constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If implicit / GOTO / I/O touched: `implicit none` / structured control / `iostat=` (+ `iomsg=`), or `fortran-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `fortitude check` with full rule set / fpm test) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- fortitude wiring stays on with C001 / implicit-typing enabled
- Public library / program contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (implicit typing / GOTO / unchecked I/O / input) before micro-opts
2. Delete dead path before adding
3. `implicit none` before old-style `implicit <type>`
4. Structured control before `GOTO` / `GO TO`
5. `iostat=` / `iomsg=` before bare `open`/`read`/`write`/`close`
6. Measure (unit / integration) before further micro-opt

Load skill **fortran** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Require implicit none in product modules`, `Wire fortitude C001 in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `F1`-`Fn` or dates. Merged commit subjects stay history.

## Standing scorecard (Fortran only)

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
| PSR Fortran alignment | checklist: fortitude lint, C001 implicit-typing, no unchecked GOTO / I/O / missing implicit none |
| CI green | `fortran-rg-gate` + `fortran-hotpath-gate` + `fortran-fortitude-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`F1`-`Fn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Fortran uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Fortran passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
