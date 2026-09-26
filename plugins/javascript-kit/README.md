# javascript-kit

JavaScript bar for the dark factory Cursor lane. **Distinct from typescript-kit** (no oxlint / tsconfig / type-aware promises). Public research pilot: expressjs/express (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/javascript`, `skills/poteto-javascript` |
| Rule | `rules/javascript.mdc` (`**/*.{js,mjs,cjs,jsx}`, not alwaysApply) |
| Tier 0 | `scripts/js-rg-gate.sh` (eval / new Function; prototype pollution; sync fs; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/js-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `JS_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/js-fmt-gate.sh` (Prettier wiring / live `--check`) |
| Tier 1 | `scripts/js-eslint-flat-gate.sh` (ESLint flat `eslint.config.*` wiring) |
| Selfcheck | `scripts/javascript-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/js-gates.yml` + `templates/eslint.config.mjs` + `templates/prettierrc.json` |
| Boundaries | `templates/async_fs_read.js`, `templates/safe_object_merge.js` |

PSR JS encode (Programming Standards Reference): ESLint plus a formatter (Prettier); explicit async error handling; avoid coercion surprises; enforce server-side input checks. Language-farm practical bar: **ESLint flat config**, **Prettier**, **no-eval**, **prototype-pollution smells**, **no sync fs on request path**. Primary authority: ECMA-262/TC39 and runtime/browser specifications.

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live `prettier --check` when on PATH unless `JS_FMT_CONFIG_ONLY=1`). ESLint flat gate checks `eslint.config.js|mjs|cjs` (legacy `.eslintrc*` alone does not pass).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/javascript-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-javascript` (JS stacks; Facepunch is Lua-only; TypeScript uses typescript-kit).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`js-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `js-hotpath-gate` fails if that wall exceeds `JS_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and expressjs/express under default budget.

### Escape

Line marker `js-rg-allow` with a short rationale. Prefer named boundaries from `templates/async_fs_read.js` / `templates/safe_object_merge.js` over scattered allows.

## Selfcheck

`bash scripts/javascript-kit-selfcheck.sh` proves rg/hotpath/fmt/eslint-flat gates discriminate fixtures, single-walk encode, budget discrimination (`JS_RG_BUDGET_MS=1`), and template presence.
