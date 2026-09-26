---
name: sql
description: SQL PSR bar. sqlfluff lint, no SELECT *, no SQL injection concat, no unsafe dynamic SQL. Use when reading or editing any .sql in a factory product.
paths: ["**/*.sql", "**/*.SQL", "**/.sqlfluff", "**/pyproject.toml", "**/.github/workflows/**"]
---

# SQL

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference SQL checks into product gates.

## PSR SQL (encoded)

1. **Agreed linter** — `sqlfluff lint` (`.sqlfluff` / `[sqlfluff]` / `[tool.sqlfluff]` / CI / live). Gate: `scripts/sql-sqlfluff-gate.sh`. Product CI: `templates/github-workflows/sql-gates.yml`. Config must keep **AM04** (or ambiguous) enabled.
2. **SELECT *** — no `SELECT *` / `table.*` without allow. Prefer explicit columns. Gate: `scripts/sql-rg-gate.sh` (single-walk). Template: `templates/parameterized_query.sql`.
3. **SQL injection concat** — no string concat / f-string / `+ @var` building of SQL without allow. Prefer bound parameters. Gate: `scripts/sql-rg-gate.sh`.
4. **Unsafe dynamic SQL** — no `EXECUTE IMMEDIATE`, `EXEC(@…)`, `sp_executesql` with concat, `PREPARE … FROM @` without allow. Gate: `scripts/sql-rg-gate.sh`. Template: `templates/safe_dynamic.sql`.
5. **Hot-path** — `scripts/sql-hotpath-gate.sh` fails if rg-gate wall exceeds `SQL_RG_BUDGET_MS` (default 250ms).

## Rules

- `sql-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-sql**.
