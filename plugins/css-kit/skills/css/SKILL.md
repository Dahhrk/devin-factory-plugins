---
name: css
description: CSS PSR bar. stylelint lint, no !important abuse, no universal selector hotpath, no expression()/behavior IE smells. Use when reading or editing any .css in a factory product.
paths: ["**/*.css", "**/*.CSS", "**/.stylelintrc", "**/.stylelintrc.json", "**/stylelint.config.*", "**/.github/workflows/**"]
---

# CSS

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference CSS checks into product gates.

## PSR CSS (encoded)

1. **Agreed linter** — `stylelint` (`.stylelintrc*` / `stylelint.config.*` / package.json `stylelint` / CI / live). Gate: `scripts/css-stylelint-gate.sh`. Product CI: `templates/github-workflows/css-gates.yml`. Config must keep **declaration-no-important** enabled and **selector-max-universal** set (product bar: `0`).
2. **!important abuse** — no `!important` without allow. Prefer specificity / `@layer`. Gate: `scripts/css-rg-gate.sh` (single-walk). Template: `templates/specificity_over_important.css`.
3. **Universal selector hotpath** — no bare `*` / `.foo *` / `* *` without allow. Prefer scoped resets. Gate: `scripts/css-rg-gate.sh`. Template: `templates/scoped_reset.css`.
4. **IE expression/behavior** — no `expression()` / `behavior:` without allow. Gate: `scripts/css-rg-gate.sh`.
5. **Hot-path** — `scripts/css-hotpath-gate.sh` fails if rg-gate wall exceeds `CSS_RG_BUDGET_MS` (default 250ms).

## Rules

- `css-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-css**.
