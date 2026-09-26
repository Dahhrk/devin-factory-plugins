---
name: javascript
description: JavaScript PSR bar (distinct from typescript-kit). ESLint flat config, Prettier, no-eval, no prototype-pollution smells, no sync fs on request path. Use when reading or editing any .js / .mjs / .cjs / .jsx in a factory product that is not TypeScript.
paths: ["**/*.js", "**/*.mjs", "**/*.cjs", "**/*.jsx", "**/eslint.config.*", "**/.prettierrc*", "**/package.json", "**/.github/workflows/**"]
---

# JavaScript

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference JavaScript checks into product gates. **Do not use typescript-kit gates for plain JS products.**

## PSR JS (encoded)

1. **Agreed formatter** — Prettier (or documented combined tool). Gate: `scripts/js-fmt-gate.sh`. Starter: `templates/prettierrc.json`.
2. **ESLint flat config** — `eslint.config.js|mjs|cjs` (legacy `.eslintrc*` alone fails). Gate: `scripts/js-eslint-flat-gate.sh` (wiring); run eslint in product CI when the host supports it. Starter: `templates/eslint.config.mjs`.
3. **no-eval** — no `eval(` / `new Function(` without allow. Gate: `scripts/js-rg-gate.sh` (single-walk).
4. **Prototype pollution** — no `__proto__` / `constructor.prototype` / `Object.assign(..., req.body|query|params)` without allow. Prefer `Object.create(null)` merges. Gate: `scripts/js-rg-gate.sh`. Template: `templates/safe_object_merge.js`.
5. **Sync fs on request path** — no `fs.*Sync` / unbound `readFileSync` etc. without allow. Prefer `fs.promises`. Gate: `scripts/js-rg-gate.sh`. Template: `templates/async_fs_read.js`.
6. **Hot-path** — `scripts/js-hotpath-gate.sh` fails if rg-gate wall exceeds `JS_RG_BUDGET_MS` (default 250ms).

## Rules

- `js-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)
- TypeScript products use **typescript-kit**, not this pack

Gates: pack README. Poteto EXIT: skill **poteto-javascript**.
