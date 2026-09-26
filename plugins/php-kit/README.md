# php-kit

PHP bar for the dark factory Cursor lane. Public research pilot: laravel/framework (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/php`, `skills/poteto-php` |
| Rule | `rules/php.mdc` (`**/*.{php,phtml}`, not alwaysApply) |
| Tier 0 | `scripts/php-rg-gate.sh` (eval; unserialize; SQL string concat; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/php-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `PHP_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/php-fmt-gate.sh` (Pint / php-cs-fixer wiring / live) |
| Tier 1 | `scripts/php-stan-gate.sh` (phpstan or psalm wiring) |
| Selfcheck | `scripts/php-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/php-gates.yml` + `templates/pint.json` / `templates/phpstan.neon.dist` |
| Boundaries | `templates/parameterized_query.php`, `templates/safe_unserialize.php` |

PSR PHP encode (Programming Standards Reference): Pint or php-cs-fixer; phpstan or psalm; no-eval; no unserialize of untrusted input; no SQL string concat with variables. Primary authority: PHP documentation and project/community style (PSR-12 / Laravel Pint).

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live pint / php-cs-fixer when on PATH unless `PHP_FMT_CONFIG_ONLY=1`). Stan gate checks phpstan or psalm config / composer require.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/php-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-php` (PHP stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`php-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `php-hotpath-gate` fails if that wall exceeds `PHP_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and laravel/framework (Database+Support+Http src) under default budget.

### Escape

Line marker `php-rg-allow` with a short rationale. Prefer named boundaries from `templates/parameterized_query.php` / `templates/safe_unserialize.php` over scattered allows.

## Selfcheck

`bash scripts/php-kit-selfcheck.sh` proves rg/hotpath/fmt/stan gates discriminate fixtures, single-walk encode, budget discrimination (`PHP_RG_BUDGET_MS=1`), and template presence.
