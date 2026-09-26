---
name: mako
description: PSR Mako encode for product Mako templates and Python wiring. Use when editing .mako / Mako HTML templates or mako.lookup / Template setup.
disable-model-invocation: false
---

# Mako

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Mako checks into product gates.

## PSR Mako (encoded)

1. **Agreed toolchain** — `mako` import / requirements|pyproject / CI. Gate: `scripts/mako-mako-gate.sh`. Product CI: `templates/github-workflows/mako-gates.yml`.
2. **disable_unicode / input_encoding footguns** — no `disable_unicode=` / risky `input_encoding` (None / latin-1 / ascii) without allow. Prefer utf-8 and Python 3 str defaults. Gate: `scripts/mako-rg-gate.sh` (single-walk). Template: `templates/lookup_no_module_dir.py`.
3. **Untrusted <%include>** — no `<%include file="...${...}..."/>` without allow. Prefer static paths. Gate: `scripts/mako-rg-gate.sh`. Template: `templates/trusted_static_include.mako`.
4. **${} without filters / |n raw** — no `|n` / empty `default_filters` / `expression_filter="n"` without allow. Prefer `<%page expression_filter="h"/>` or `|h`. Gate: `scripts/mako-rg-gate.sh`. Templates: `templates/page_html_filter.mako`, `templates/filtered_expression.mako`.
5. **module_directory code-exec cache** — no `module_directory=` without allow (compiled `.py` modules are code-exec). Prefer no module cache or a locked-down path with allow. Gate: `scripts/mako-rg-gate.sh`. Template: `templates/lookup_no_module_dir.py`.
6. **Hot-path** — `scripts/mako-hotpath-gate.sh` fails if rg-gate wall exceeds `MAKO_RG_BUDGET_MS` (default 250ms).

## Rules

- `mako-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-mako**.
