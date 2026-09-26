---
name: poteto-just
description: Poteto-mode bar for Just / Build & ops products. Use for /poteto-mode on Just work, or when Dark asks for poteto bar on justfiles. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Just

Apply `/poteto-mode` non-negotiables, then this leaf for justfiles / *.just and just wiring.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/just-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/just-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `JUST_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/just-just-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious script / dotenv / import constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If [script] / shebang / dotenv / export / import / mod / curl|bash touched: no unchecked script/shebang + no dotenv secrets + no secret export + static relative import + no curl|bash, or `just-rg-allow` on the smell line when intentional.
7. Stricter product gates (shellcheck on recipes, just --fmt --check) override when present. Prove on the real artifact (`just` run).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- just wiring stays on for Just products
- Public target / install contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (dotenv / export secrets / import path / curl|bash) before micro-opts
2. Delete dead path before adding
3. Line recipes before unchecked `[script]` / shebang
4. CI/OIDC secrets before `set dotenv-*`
5. Host env before `export SECRET`
6. Static relative `import 'rules.just'` before `import '{{...}}'` / `~/` / absolute
7. Checksum install before pipe-to-shell
8. Measure (`just`) before further micro-opt

Load skill **just** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban dotenv secrets in just recipes`, `Require static just imports`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Just only)

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
| PSR Just alignment | checklist: just wiring, no unchecked script/shebang / dotenv secrets / export secrets / include untrusted / curl\|bash |
| CI green | `just-rg-gate` + `just-hotpath-gate` + `just-just-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Just uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Just passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
