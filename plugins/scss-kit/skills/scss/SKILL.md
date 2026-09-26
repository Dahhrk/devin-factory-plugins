---
name: scss
description: SCSS/Sass PSR bar. dart-sass/sass wiring, no !important abuse, no @extend overuse, no /deep/ or >>>, nesting depth ≤4. Use when reading or editing any .scss/.sass in a factory product.
paths: ["**/*.scss", "**/*.sass", "**/*.SCSS", "**/*.SASS", "**/package.json", "**/sass.config.*", "**/.github/workflows/**"]
---

# SCSS / Sass

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference SCSS checks into product gates. One kit covers both `.scss` (SCSS) and `.sass` (indented) syntax.

## PSR SCSS (encoded)

1. **Agreed compiler** — `sass` / dart-sass (`package.json` `sass` / `dart-sass` / `sass.config.*` / CI / live). Gate: `scripts/scss-sass-gate.sh`. Product CI: `templates/github-workflows/scss-gates.yml`.
2. **!important abuse** — no `!important` without allow. Prefer specificity / `@layer` / mixin. Gate: `scripts/scss-rg-gate.sh` (single-walk). Template: `templates/specificity_over_important.scss`.
3. **@extend overuse** — no `@extend` without allow. Prefer mixins (dart-sass `@extend` graph is complex). Gate: `scripts/scss-rg-gate.sh`. Template: `templates/mixin_over_extend.scss`.
4. **/deep/ or >>>** — no `/deep/` / `>>>` without allow. Prefer `:deep()` / BEM. Gate: `scripts/scss-rg-gate.sh`. Template: `templates/no_deep_combinator.scss`.
5. **Nesting depth ≤4** — brace depth (`.scss`) / indent depth (`.sass`) >4 banned. Prefer flat BEM. Gate: `scripts/scss-rg-gate.sh` (file-level). Template: `templates/flat_nesting.scss`.
6. **Hot-path** — `scripts/scss-hotpath-gate.sh` fails if rg-gate wall exceeds `SCSS_RG_BUDGET_MS` (default 250ms).

## Rules

- `scss-rg-allow` on the same line as the smell, with a short rationale (nesting: `scss-rg-allow nest …` somewhere in the file)
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-scss**.
