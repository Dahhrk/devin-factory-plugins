---
name: tailwind
description: PSR Tailwind encode for product Tailwind CSS. Use when editing Tailwind templates, CSS entry, or tailwindcss wiring.
disable-model-invocation: false
---

# Tailwind CSS

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Tailwind checks into product gates.

## PSR Tailwind (encoded)

1. **Agreed toolchain** — `tailwindcss` in `package.json` (`"tailwindcss":`) / `tailwind.config.*` / `@import "tailwindcss"` / CI. Gate: `scripts/tailwind-tailwind-gate.sh`. Product CI: `templates/github-workflows/tailwind-gates.yml`.
2. **`@apply` overuse** — no `@apply` without allow. Prefer utilities in markup or real framework components (Tailwind docs: reusing styles). Gate: `scripts/tailwind-rg-gate.sh` (single-walk). Template: `templates/utility_over_apply.html`.
3. **Arbitrary-value sprawl** — no `util-[…]` / `[prop:…]` without allow. Prefer theme tokens (`p-4`, `bg-red-500`, CSS variables in theme). Gate: `scripts/tailwind-rg-gate.sh`. Template: `templates/design_tokens_not_arbitrary.html`.
4. **Safelist abuse** — no `safelist:` / blanket `@source inline(…)` without allow (defeats purge / source scanning). Prefer correct content / `@source` globs. Gate: `scripts/tailwind-rg-gate.sh`. Template: `templates/no_safelist_abuse.js`.
5. **Content-path miss / purge footguns** — no empty `content: []`; no dynamic class concat (`'bg-' + color`) without allow. Prefer complete class strings + content / `@source` covering templates. Gate: `scripts/tailwind-rg-gate.sh`. Template: `templates/content_paths_complete.js`.
6. **Hot-path** — `scripts/tailwind-hotpath-gate.sh` fails if rg-gate wall exceeds `TAILWIND_RG_BUDGET_MS` (default 250ms).

## Rules

- `tailwind-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-tailwind**.
