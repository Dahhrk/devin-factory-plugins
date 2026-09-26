# sql-kit

SQL bar for the dark factory Cursor lane. Public research pilot: sqlfluff/sqlfluff (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/sql`, `skills/poteto-sql` |
| Rule | `rules/sql.mdc` (`**/*.{sql,SQL}`, not alwaysApply) |
| Tier 0 | `scripts/sql-rg-gate.sh` (`SELECT *`; SQL injection concat; unsafe dynamic SQL; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/sql-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `SQL_RG_BUDGET_MS`) |
| Tier 1 | `scripts/sql-sqlfluff-gate.sh` (sqlfluff lint wiring / live; requires AM04 / ambiguous SELECT * rule) |
| Selfcheck | `scripts/sql-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/sql-gates.yml` |
| Boundaries | `templates/parameterized_query.sql`, `templates/safe_dynamic.sql` |
| Lint starter | `templates/.sqlfluff` |

PSR SQL encode (Programming Standards Reference): sqlfluff lint; no `SELECT *` without allow; no SQL string concat / injection smells without allow; no unsafe dynamic SQL (`EXECUTE IMMEDIATE`, `EXEC(@…)`, `sp_executesql` with concat) without allow. Primary authority: SQL dialect docs and sqlfluff (AM04 and related).

Compose with `/poteto-mode`. Tier 1 sqlfluff checks wiring (live `sqlfluff lint` when on PATH unless `SQL_SQLFLUFF_CONFIG_ONLY=1`). Config must keep AM04 (or ambiguous group) enabled.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/sql-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-sql` (SQL stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`sql-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `sql-hotpath-gate` fails if that wall exceeds `SQL_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and sqlfluff/sqlfluff `test/fixtures/linter` under default budget.

### Escape

Line marker `sql-rg-allow` with a short rationale. Prefer named boundaries from `templates/parameterized_query.sql` / `templates/safe_dynamic.sql` over scattered allows.

## Selfcheck

`bash scripts/sql-kit-selfcheck.sh` proves rg/hotpath/sqlfluff gates discriminate fixtures, single-walk encode, budget discrimination (`SQL_RG_BUDGET_MS=1`), AM04/rules bar, and template presence.
