# typescript-kit

TypeScript bar for the dark factory Cursor lane. Public research pilots: eslint/eslint (MIT), hoppscotch/hoppscotch, payloadcms/payload, calcom/cal.com, trpc/trpc, microsoft/TypeScript `packages/typescript`.

| Surface | Path |
|---------|------|
| Skills | `skills/typescript`, `skills/poteto-typescript` |
| Rules | `rules/typescript.mdc`, `rules/typescript-exhaustive-switch.mdc` |
| Tier 0 | `scripts/ts-rg-gate.sh` (any / assertions / DOM `!` / JSON.parse / global fetch / URL / env; method `.fetch` OK; product scans `.d.ts`; `TS_RG_SKIP_DTS=1` for library hosts; **single-walk** union scan; requires **rg**) |
| Tier 0.5 | `scripts/ts-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `TS_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/ts-strict-gate.sh` (strict via extends; typecheck aliases) |
| Tier 0.5 | `scripts/ts-runtime-gate.sh` (runtime/drive proof script required) |
| Tier 0.5 | `scripts/ts-oxlint-gate.sh` (factory rules incl. typeAware floating/misused; pinned oxlint + tsgolint; offline via `TS_OXLINT_BIN` / `TS_OXLINT_OFFLINE=1`) |
| Oxlint | `templates/oxlintrc.json` + `templates/oxlint.version` + `templates/oxlint-tsgolint.version` |
| Boundaries | `templates/env-schema.ts`, `templates/typed-parse.ts` |
| Selfcheck | `scripts/ts-kit-selfcheck.sh` (parallel probes + hotpath budget + type-aware float live) |
| Product CI | `templates/github-workflows/ts-gates.yml` |

PSR encode: handbook/compiler options; strict checking; no unexplained any/assertions (including `as unknown as`); described `@ts-expect-error`; validate JSON/DOM/global-fetch/URL/env at named boundaries; CI typecheck; runtime/drive proof; exhaustive switches; product adopts oxlint template including type-aware `no-floating-promises` + `no-misused-promises` (void-return async callbacks; JSX attributes unchecked).

### Hot-path

`ts-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `ts-hotpath-gate` fails if that wall exceeds `TS_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture ~45ms; eslint/lib ~55–60ms; hop-common / payload / cal apps/web ~85–100ms.

### `.d.ts` / boundary allow

Product public `.d.ts` is scanned (`: any` fails). Library host research: `TS_RG_SKIP_DTS=1`. Bare JSON/fetch/URL/env need `ts-rg-allow` on a named parser line. Method `.fetch(` and whole-object `process.env` into a schema are allowed.

### Type-aware oxlint

Floating/misused promises need `options.typeAware` + pinned `oxlint-tsgolint`. Silent rules without tsgolint are refused.

Compose with `/poteto-mode` and pstack `typescript-best-practices`. Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins`, `Dahhrk/zcode-factory`. Standing scorecard: `skills/poteto-typescript`. PR titles: plain work descriptions only (never `pass N`).

## Selfcheck

`bash scripts/ts-kit-selfcheck.sh` proves rg/strict/runtime/oxlint/hotpath gates, extends walk, `.d.ts` policy, fetch vs `.fetch`, bare `@ts-expect-error`, templates, pins, offline refusal, single-walk encode, budget discrimination (`TS_RG_BUDGET_MS=1`), and type-aware live fail on `testdata/oxlint-float-bad` when bins/npx exist.
