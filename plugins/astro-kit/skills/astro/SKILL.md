---
name: astro
description: Astro PSR bar. astro check/build wiring, no client:load abuse, no set:html without sanitize, no define:vars XSS smells. Use when reading or editing any .astro in a factory product.
paths: ["**/*.astro", "**/package.json", "**/astro.config.*", "**/.github/workflows/**"]
---

# Astro

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Astro checks into product gates.

## PSR Astro (encoded)

1. **Agreed toolchain** — `astro` (`package.json` `astro` / `astro.config.*` / CI `astro check` / `astro build` / live). Gate: `scripts/astro-astro-gate.sh`. Product CI: `templates/github-workflows/astro-gates.yml`.
2. **client:load abuse** — no `client:load` without allow. Prefer `client:visible` / `client:idle` / `client:media` / static HTML. Gate: `scripts/astro-rg-gate.sh` (single-walk). Template: `templates/client_visible_not_load.astro`.
3. **set:html without sanitize** — no `set:html` without `DOMPurify.sanitize` / `sanitizeHtml` / `.sanitize(` on the same line (or allow). Prefer auto-escaped `{expr}`. Gate: `scripts/astro-rg-gate.sh`. Template: `templates/set_html_sanitized.astro`.
4. **define:vars XSS** — no `define:vars` without allow. Prefer `data-*` + module scripts (define:vars inlines into `<script>`; historical XSS via incomplete `</script>` sanitization). Gate: `scripts/astro-rg-gate.sh`. Template: `templates/data_attrs_not_define_vars.astro`.
5. **Hot-path** — `scripts/astro-hotpath-gate.sh` fails if rg-gate wall exceeds `ASTRO_RG_BUDGET_MS` (default 250ms).

## Rules

- `astro-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-astro**.
