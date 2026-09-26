---
name: poteto-slint
description: Poteto-mode bar for Slint products. Use for /poteto-mode on Slint work, or when Dark asks for poteto bar on Slint. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Slint

Apply `/poteto-mode` non-negotiables, then this leaf for Slint packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/slint-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/slint-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `SLINT_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/slint-cargo-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for unit contracts, or required allow markers.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If debug() / clone_strong / unsafe-in-.on_ host touched: remove debug, switch to as_weak, or isolate unsafe with SAFETY docs + `slint-rg-allow` when intentional.
7. Stricter product gates (live `cargo build`, clippy, Slint interpreter checks) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- slint / Cargo (or CMake) wiring stays on
- Public API contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (.slint debug hygiene / clone_strong / unsafe-in-callback-host) before micro-opts
2. Delete dead path before adding
3. as_weak before clone_strong in callbacks
4. Safe callback host before unsafe { in .on_ files
5. Measure (`cargo build` / smoke) before further micro-opt

Load skill **slint** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban leftover debug() in slint-kit`, `Require as_weak for Slint callback capture`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `A1`-`An` or dates. Merged commit subjects stay history.

## Standing scorecard (Slint only)

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
| PSR Slint alignment | checklist: no debug() in .slint, as_weak for callbacks, no unsafe { in .on_ hosts, slint/Cargo wiring |
| CI green | `slint-rg-gate` + `slint-hotpath-gate` + `slint-cargo-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`A1`-`An` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Slint uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Slint passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
