---
name: poteto-java
description: Poteto-mode bar for Java products. Use for /poteto-mode on Java work, or when Dark asks for poteto bar on Java. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Java

Apply `/poteto-mode` non-negotiables, then this leaf for Java libraries / services / CLIs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/java-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/java-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `JAVA_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/java-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/java-checkstyle-ci-gate.sh <product-root>` exits 0.
5. `bash scripts/java-nullability-gate.sh <product-root>` exits 0.
6. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious nullability / concurrency / resource constraints.
7. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
8. If System.out / SQL concat / NPE catch touched: logger / PreparedStatement / nullable contract, `java-rg-allow` on the smell line when intentional.
9. Stricter product gates (live Checkstyle, Error Prone, NullAway) override when present. Prove on the real artifact (tests / Checkstyle / Error Prone build).
10. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- Formatter / Checkstyle / nullability wiring stay on
- Public API unchanged unless the goal is an API break
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (SQL / null / parse / net) before micro-opts
2. Delete dead path before adding
3. Logger before System.out
4. PreparedStatement before SQL string concat
5. Measure (tests / Checkstyle / Error Prone) before further micro-opt

Load skill **java** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace System.out with logger`, `Wire Checkstyle in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Java only)

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
| PSR Java alignment | checklist: formatter (google-java-format/Spotless), Checkstyle/Error Prone wiring, nullability contracts, no unchecked System.out/printStackTrace/SQL concat/NPE catch |
| CI green | `java-rg-gate` + `java-hotpath-gate` + `java-fmt-gate` + `java-checkstyle-ci-gate` + `java-nullability-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Java uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Java passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
