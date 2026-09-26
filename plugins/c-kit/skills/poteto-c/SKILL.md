---
name: poteto-c
description: Poteto-mode bar for C products. Use for /poteto-mode on C work, or when Dark asks for poteto bar on C. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto C

Apply `/poteto-mode` non-negotiables, then this leaf for C libraries / CLIs / services.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/c-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/c-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `C_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/c-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/c-warn-gate.sh <product-root>` exits 0.
5. `bash scripts/c-san-ci-gate.sh <product-root>` exits 0.
6. `bash scripts/c-malloc-gate.sh <product-root> [paths...]` exits 0.
7. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious ownership / bounds / UB constraints.
8. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
9. If strcpy/sprintf/malloc touched: bounded helpers, NULL checks, `c-rg-allow` on the smell line when intentional.
10. Stricter product gates (clang-tidy, `-Werror`, CI sanitizer jobs) override when present. Prove on the real artifact (tests / sanitizer build).
11. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- `clang-format` / `-Wall -Wextra` wiring stay on
- Public ABI unchanged unless the goal is an ABI break
- Sanitizer CI wiring stays on
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (buffer / alloc / parse / net) before micro-opts
2. Delete dead path before adding
3. Bounded string helpers before more sprintf
4. NULL-checked alloc before assuming success
5. Measure (perf counters / sanitizers) before further micro-opt

Load skill **c** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Bound process title copies with snprintf`, `Wire ASAN in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (C only)

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
| PSR C alignment | checklist: clang-format, -Wall -Wextra, sanitizer wiring, no unchecked strcpy/sprintf/gets, malloc NULL checks |
| CI green | `c-rg-gate` + `c-hotpath-gate` + `c-fmt-gate` + `c-warn-gate` + `c-san-ci-gate` + `c-malloc-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. C uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm C passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
