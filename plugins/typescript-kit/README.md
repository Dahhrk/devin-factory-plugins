# typescript-kit

TypeScript bar for the dark factory Cursor lane. Public research pilots: eslint/eslint (MIT), trpc/trpc next-minimal-starter (MIT app).

| Surface | Path |
|---------|------|
| Skills | `skills/typescript`, `skills/poteto-typescript` |
| Rules | `rules/typescript.mdc`, `rules/typescript-exhaustive-switch.mdc` |
| Tier 0 | `scripts/ts-rg-gate.sh` (any / as any / as unknown as / @ts-ignore / bare @ts-expect-error / DOM `!` / bare JSON.parse / fetch / new URL / process.env accessors; product scans `.d.ts`, library research may set `TS_RG_SKIP_DTS=1`) |
| Tier 0.5 | `scripts/ts-strict-gate.sh` (strict via extends; typecheck aliases) |
| Tier 0.5 | `scripts/ts-runtime-gate.sh` (runtime/drive proof script required) |
| Tier 0.5 | `scripts/ts-oxlint-gate.sh` (require `.oxlintrc.json` with factory rules; live oxlint unless `TS_OXLINT_CONFIG_ONLY=1`) |
| Oxlint | `templates/oxlintrc.json` (`no-explicit-any`, `no-non-null-assertion`, `switch-exhaustiveness-check`, described `ban-ts-comment`) |
| Selfcheck | `scripts/ts-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/ts-gates.yml` (rg + strict + runtime + oxlint adoption + typecheck + lint + `npm test`) |

PSR TypeScript encode: handbook/compiler options + ECMAScript semantics; enable strict checking; avoid unexplained any and assertions (including double `as unknown as`); require described `@ts-expect-error`; validate external data at runtime (JSON / DOM / fetch / URL / env behind named boundaries); type-check in CI; test emitted/runtime behaviour; exhaustive switches on discriminated unions; product must adopt the oxlint template (not only ship the pack file).

### `.d.ts` product vs library

- **Product (default):** public `.d.ts` is scanned. `: any` in product public types fails the bar.
- **Library / host API research:** set `TS_RG_SKIP_DTS=1` when declaration files are intentional plugin/parser host surface (eslint-shaped). Prefer a single-line `ts-rg-allow` when only one site needs the escape.

### Boundary allow

Bare `JSON.parse` / `fetch` / `new URL` / `process.env.X` in scanned sources fail unless the line carries `ts-rg-allow` on a named parse helper.

Compose with `/poteto-mode` and pstack `typescript-best-practices`. Does not replace product oxlint anti-slop plugins or Control-Glass UI gates.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/typescript-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-typescript` (TS stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

## Selfcheck

`bash scripts/ts-kit-selfcheck.sh` proves rg/strict/runtime/oxlint gates, extends walk, product-vs-library `.d.ts` policy, fetch/URL/env discrimination, and oxlint template substance.
