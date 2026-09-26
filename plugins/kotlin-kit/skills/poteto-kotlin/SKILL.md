---
name: poteto-kotlin
description: Poteto-mode bar for Kotlin products. Use for /poteto-mode on Kotlin work, or when Dark asks for poteto bar on Kotlin. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Kotlin

Apply `/poteto-mode` non-negotiables, then this leaf for Kotlin packages / services / CLIs / Ktor apps.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/kotlin-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/kotlin-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `KOTLIN_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/kotlin-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/kotlin-detekt-gate.sh <product-root>` exits 0.
5. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious concurrency / null / SQL constraints.
6. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
7. If `!!` / `runBlocking` / SQL concat touched: optional bind / suspend / prepared statement, `kotlin-rg-allow` on the smell line when intentional.
8. Stricter product gates (live ktlint / detekt) override when present. Prove on the real artifact (tests / detekt).
9. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- ktlint and detekt wiring stay on
- Public API unchanged unless the goal is an API break
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (`!!` / `runBlocking` / SQL concat / input) before micro-opts
2. Delete dead path before adding
3. `?.` / `?:` / `requireNotNull` before `!!`
4. `suspend` / `coroutineScope` before `runBlocking` on hot paths
5. Prepared statements / named params before SQL string concat
6. Measure (tests / detekt) before further micro-opt

Load skill **kotlin** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace !! with requireNotNull`, `Add detekt yml`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Kotlin only)

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
| PSR Kotlin alignment | checklist: ktlint, detekt, no unchecked `!!` / `runBlocking` on hot paths / SQL concat |
| CI green | `kotlin-rg-gate` + `kotlin-hotpath-gate` + `kotlin-fmt-gate` + `kotlin-detekt-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Kotlin uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Kotlin passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
