---
name: php
description: PHP PSR bar. Pint/php-cs-fixer, phpstan/psalm, no-eval, no unserialize of untrusted input, no SQL string concat. Use when reading or editing any .php / .phtml in a factory product.
paths: ["**/*.php", "**/*.phtml", "**/pint.json", "**/.php-cs-fixer.php", "**/phpstan.neon*", "**/psalm.xml*", "**/composer.json", "**/.github/workflows/**"]
---

# PHP

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference PHP checks into product gates.

## PSR PHP (encoded)

1. **Agreed formatter** — Laravel Pint or php-cs-fixer (PSR-12). Gate: `scripts/php-fmt-gate.sh`. Starter: `templates/pint.json`.
2. **phpstan or psalm** — config or composer require. Gate: `scripts/php-stan-gate.sh` (wiring); run analyzer in product CI when the host supports it.
3. **no-eval** — no `eval(` without allow. Gate: `scripts/php-rg-gate.sh` (single-walk).
4. **unserialize** — no `unserialize(` of untrusted input without allow. Prefer `json_decode` or `unserialize($x, ['allowed_classes' => ...])`. Gate: `scripts/php-rg-gate.sh`. Template: `templates/safe_unserialize.php`.
5. **SQL string concat** — no `"SELECT ...".$id` / `whereRaw(...$var)` without allow. Prefer bound parameters / query builder. Gate: `scripts/php-rg-gate.sh`. Template: `templates/parameterized_query.php`.
6. **Hot-path** — `scripts/php-hotpath-gate.sh` fails if rg-gate wall exceeds `PHP_RG_BUDGET_MS` (default 250ms).

## Rules

- `php-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-php**.
