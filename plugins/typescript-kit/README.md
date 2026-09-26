# typescript-kit

TypeScript bar for the dark factory Cursor lane. Public research pilots: eslint/eslint (MIT library host), trpc/trpc next-prisma-starter (MIT product app), microsoft/TypeScript `packages/typescript` (Apache-2.0 bounded subtree).

| Surface | Path |
|---------|------|
| Skills | `skills/typescript`, `skills/poteto-typescript` |
| Rules | `rules/typescript.mdc`, `rules/typescript-exhaustive-switch.mdc` |
| Tier 0 | `scripts/ts-rg-gate.sh` (any / as any / as unknown as / @ts-ignore / bare @ts-expect-error / DOM `!` / bare JSON.parse / **global** fetch / new URL / process.env accessors; method `.fetch` allowed; product scans `.d.ts`, library research may set `TS_RG_SKIP_DTS=1`; parallel smell scans) |
| Tier 0.5 | `scripts/ts-strict-gate.sh` (strict via extends; typecheck aliases) |
| Tier 0.5 | `scripts/ts-runtime-gate.sh` (runtime/drive proof script required) |
| Tier 0.5 | `scripts/ts-oxlint-gate.sh` (require `.oxlintrc.json` with factory rules; live oxlint pinned via `templates/oxlint.version` / `TS_OXLINT_VERSION`; prefer `TS_OXLINT_BIN` then PATH then `node_modules/.bin` then `npx oxlint@$pin`; `TS_OXLINT_OFFLINE=1` refuses npx; `TS_OXLINT_CONFIG_ONLY=1` config-only) |
| Oxlint | `templates/oxlintrc.json` + `templates/oxlint.version` (pin; never floating-latest) |
| Boundaries | `templates/env-schema.ts`, `templates/typed-parse.ts` (named env / JSON parse) |
| Selfcheck | `scripts/ts-kit-selfcheck.sh` (parallel probes) |
| Product CI | `templates/github-workflows/ts-gates.yml` (rg + strict + runtime + oxlint adoption + typecheck + lint + `npm test`) |

PSR TypeScript encode: handbook/compiler options + ECMAScript semantics; enable strict checking; avoid unexplained any and assertions (including double `as unknown as`); require described `@ts-expect-error`; validate external data at runtime (JSON / DOM / global fetch / URL / env behind named boundaries); type-check in CI; test emitted/runtime behaviour; exhaustive switches on discriminated unions; product must adopt the oxlint template (not only ship the pack file).

### `.d.ts` product vs library

- **Product (default):** public `.d.ts` is scanned. `: any` in product public types fails the bar.
- **Library / host API research:** set `TS_RG_SKIP_DTS=1` when declaration files are intentional plugin/parser host surface (eslint-shaped). Prefer a single-line `ts-rg-allow` when only one site needs the escape.

### Boundary allow

Bare `JSON.parse` / global `fetch` / `new URL` / `process.env.X` in scanned sources fail unless the line carries `ts-rg-allow` on a named parse helper. Method `.fetch(` (tRPC / React Query) is not gated. Whole-object `process.env` passed into a named schema/parser is allowed. Copy `templates/env-schema.ts` / `templates/typed-parse.ts` when the product needs a starter boundary.

Compose with `/poteto-mode` and pstack `typescript-best-practices`. Does not replace product oxlint anti-slop plugins or Control-Glass UI gates.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/typescript-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-typescript` (TS stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

## Selfcheck

`bash scripts/ts-kit-selfcheck.sh` proves rg/strict/runtime/oxlint gates, extends walk, product-vs-library `.d.ts` policy, global-fetch vs method-`.fetch`, portable bare `@ts-expect-error`, env/JSON templates, oxlint template substance, oxlint pin (no floating-latest), and offline refusal without a local binary.
