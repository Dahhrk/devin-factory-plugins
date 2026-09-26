---
name: poteto-sql
description: Poteto-mode bar for SQL products. Use for /poteto-mode on SQL work, or when Dark asks for poteto bar on SQL. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto SQL

Apply `/poteto-mode` non-negotiables, then this leaf for SQL schemas / migrations / query packs / dbt models / stored procedures.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/sql-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/sql-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `SQL_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/sql-sqlfluff-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious dialect / lock / migration constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If `SELECT *` / SQL concat / unsafe dynamic SQL touched: explicit columns / binds / parameterized dynamic SQL, or `sql-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `sqlfluff lint` with full rule set) override when present. Prove on the real artifact (tests / dry-run migrations).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- sqlfluff lint wiring stays on with AM04 (SELECT *) enabled
- Public schema / migration contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (`SELECT *` / injection concat / unsafe dynamic SQL / input) before micro-opts
2. Delete dead path before adding
3. Explicit columns before `SELECT *`
4. Bound parameters before SQL string concat
5. Parameterized dynamic SQL before `EXECUTE IMMEDIATE` / `EXEC(@…)`
6. Measure (dialect tests / migration dry-run) before further micro-opt

Load skill **sql** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace SELECT * with explicit columns`, `Wire sqlfluff AM04 in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (SQL only)

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
| PSR SQL alignment | checklist: sqlfluff lint, AM04, no unchecked `SELECT *` / SQL concat / unsafe dynamic SQL |
| CI green | `sql-rg-gate` + `sql-hotpath-gate` + `sql-sqlfluff-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. SQL uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm SQL passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
