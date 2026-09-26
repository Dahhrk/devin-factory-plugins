---
name: pug
description: PSR Pug encode for product Pug templates. Use when editing .pug / .jade or pug compile/render wiring.
disable-model-invocation: false
---

# Pug

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Pug checks into product gates.

## PSR Pug (encoded)

1. **Agreed toolchain** — `pug` in `package.json` (`"pug":`) / pug config / CI. Gate: `scripts/pug-pug-gate.sh`. Product CI: `templates/github-workflows/pug-gates.yml`.
2. **Unescaped buffered XSS** — no `!=` / `!{…}` without allow (docs: unescaped buffered; unsafe for user input). Prefer buffered `=` / `#{…}`. Gate: `scripts/pug-rg-gate.sh` (single-walk). Template: `templates/buffered_escaped_output.pug`.
3. **Include of untrusted paths** — no `include #{…}` / `include !{…}` without allow. Prefer static trusted paths (relative or basedir). Gate: `scripts/pug-rg-gate.sh`. Template: `templates/trusted_static_include.pug`.
4. **Mixin injection** — no dynamic mixin names `+#{…}` / `+!{…}` without allow. Prefer static `+name`. Gate: `scripts/pug-rg-gate.sh`. Template: `templates/static_mixin_call.pug`.
5. **Hot-path** — `scripts/pug-hotpath-gate.sh` fails if rg-gate wall exceeds `PUG_RG_BUDGET_MS` (default 250ms).

## Rules

- `pug-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-pug**.
