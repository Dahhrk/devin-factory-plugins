---
name: poteto-shell
description: Poteto-mode bar for Shell products. Use for /poteto-mode on Shell work, or when Dark asks for poteto bar on Shell. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Shell

Apply `/poteto-mode` non-negotiables, then this leaf for product `.sh` / `.bash` / CLI glue.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/sh-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/sh-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `SH_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/sh-shellcheck-gate.sh <product-root> [paths...]` exits 0.
4. `bash scripts/sh-fmt-gate.sh <product-root> [paths...]` exits 0.
5. `bash scripts/sh-strict-gate.sh <product-root> [paths...]` exits 0 (or `SH_STRICT_GATE_SKIP=1` documented for sourced library fragments).
6. `bash scripts/sh-test-gate.sh <product-root>` exits 0.
7. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious external constraints.
8. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
9. If temps / downloads / expansions touched: mktemp+trap, quote paths, no eval / curl|sh (see `templates/safe_temp.sh` / `templates/quoted_expand.sh`).
10. Stricter product gates (bats, shellspec, Makefile check) override when present. Prove on the real artifact.
11. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- ShellCheck warning+ and shfmt stay clean
- Public CLI flags unchanged unless the goal is a CLI break
- `set -euo pipefail` stays on product entrypoints
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (quote / temp / download / eval) before micro-opts
2. Delete dead path before adding
3. Explicit failure (`set -euo pipefail`) before more control flow
4. Named boundaries (`safe_temp`, quoted expand) before scattered `sh-rg-allow`
5. Measure (time, `SH_RG_BUDGET_MS`) before further micro-opt

Load skill **shell** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Quote install path expansions`, `Wire ShellCheck in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Shell only)

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
| PSR Shell alignment | checklist: ShellCheck, shfmt, quote expansions, set -euo pipefail, mktemp+trap, tests for filenames/signals/empty, no eval/curl\|sh |
| CI green | `sh-rg-gate` + `sh-hotpath-gate` + `sh-shellcheck-gate` + `sh-fmt-gate` + `sh-strict-gate` + `sh-test-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Shell uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Shell passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
