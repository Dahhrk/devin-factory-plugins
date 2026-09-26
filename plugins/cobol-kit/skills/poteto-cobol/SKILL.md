---
name: poteto-cobol
description: Poteto-mode bar for COBOL products. Use for /poteto-mode on COBOL work, or when Dark asks for poteto bar on COBOL. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto COBOL

Apply `/poteto-mode` non-negotiables, then this leaf for GnuCOBOL / enterprise COBOL packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/cobol-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/cobol-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `COBOL_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/cobol-cobc-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for copybook contracts, or required allow markers.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If GOTO / ALTER / ACCEPT / IF-without-END-IF touched: replace with PERFORM/EVALUATE / ON EXCEPTION / END-IF, or `cobol-rg-allow` on the smell line when intentional (END-IF imbalance needs a matching END-IF).
7. Stricter product gates (live `cobc -Wall -Werror=typing`, cobol-check) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- cobc wiring stays on
- Public copybook / API contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (GOTO / ALTER / ACCEPT / END-IF) before micro-opts
2. Delete dead path before adding
3. PERFORM / EVALUATE before GOTO
4. Explicit PERFORM targets before ALTER
5. ON EXCEPTION before bare ACCEPT
6. Measure (`cobc` / smoke) before further micro-opt

Load skill **cobol** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban GOTO in cobol-kit`, `Require cobc wiring for COBOL products`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `A1`-`An` or dates. Merged commit subjects stay history.

## Standing scorecard (COBOL only)

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
| PSR COBOL alignment | checklist: no GOTO/ALTER, checked ACCEPT, END-IF hygiene, cobc wiring |
| CI green | `cobol-rg-gate` + `cobol-hotpath-gate` + `cobol-cobc-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`A1`-`An` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. COBOL uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm COBOL passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
