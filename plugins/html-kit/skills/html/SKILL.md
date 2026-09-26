---
name: html
description: HTML PSR bar. htmlhint lint, no missing alt, no inline JS/CSS smells, no external script without integrity where relevant. Use when reading or editing any .html in a factory product.
paths: ["**/*.html", "**/*.htm", "**/*.HTML", "**/*.HTM", "**/.htmlhintrc", "**/.htmlhint.json", "**/.github/workflows/**"]
---

# HTML

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference HTML checks into product gates.

## PSR HTML (encoded)

1. **Agreed linter** — `htmlhint` (`.htmlhintrc` / `.htmlhint.json` / package.json `htmlhint` / CI / live). Gate: `scripts/html-htmlhint-gate.sh`. Product CI: `templates/github-workflows/html-gates.yml`. Config must keep **alt-require**, **inline-script-disabled**, and **inline-style-disabled** enabled.
2. **Missing alt** — no `<img>` without `alt=` (unless `aria-hidden="true"`) without allow. Gate: `scripts/html-rg-gate.sh` (single-walk). Template: `templates/accessible_img.html`.
3. **Inline JS/CSS** — no `style=`, `on*` handlers, `javascript:` URLs, inline `<script>` / `<style>` without allow. Prefer external assets. Gate: `scripts/html-rg-gate.sh`.
4. **Script integrity** — no external `<script src="https?://…">` without `integrity=` (SRI) where relevant without allow. Gate: `scripts/html-rg-gate.sh`. Template: `templates/external_script_sri.html`.
5. **Hot-path** — `scripts/html-hotpath-gate.sh` fails if rg-gate wall exceeds `HTML_RG_BUDGET_MS` (default 250ms).

## Rules

- `html-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-html**.
