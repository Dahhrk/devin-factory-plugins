---
name: typescript
description: TypeScript PSR bar. Strict checking (extends-aware), oxlint adoption gate (pinned offline-capable live run), global-fetch/URL/env + JSON/DOM rg boundaries (method .fetch allowed), env-schema + typed-parse templates, runtime/drive proof, product-vs-library .d.ts policy, no unexplained any/assertions/double-assertion, described @ts-expect-error, typecheck aliases. Use when reading or editing any .ts or .tsx in a factory product.
paths: ["**/*.ts", "**/*.tsx", "**/tsconfig*.json", "**/.oxlintrc.json"]
---

# TypeScript

Apply pstack **principle-type-system-discipline** and **typescript-best-practices** first. This skill encodes Programming Standards Reference TypeScript checks into product gates.

## PSR TypeScript (encoded)

1. **Handbook + compiler options** - follow TypeScript handbook idioms; product `tsconfig` is the contract.
2. **Strict checking** - `strict: true` on the app config or an `extends` parent. Gate: `scripts/ts-strict-gate.sh` (walks extends; accepts tsconfig.app/json/base/build/types).
3. **Avoid unexplained any and assertions** - ban `: any`, `as any`, `as unknown as`, bare `@ts-ignore` / `@ts-nocheck`, and `@ts-expect-error` without a trailing description. Prefer `unknown` + parse. Non-null `!` on external lookups is an unexplained assertion. Gate: `scripts/ts-rg-gate.sh` (portable bare expect-error filter; no PCRE2 required). Product oxlint: `scripts/ts-oxlint-gate.sh` + `templates/oxlintrc.json` (`typescript/no-explicit-any`, `typescript/no-non-null-assertion`, `typescript/ban-ts-comment` allow-with-description).
4. **Validate external data at runtime** - DOM nodes, `JSON.parse`, **global** `fetch`, `new URL`, and `process.env.*` cross into named domain types at the boundary. No postfix `!` on `getElementById` / `querySelector*`. Bare calls fail rg unless `ts-rg-allow` on the named parser line. Method `.fetch(` is allowed. Whole-object `process.env` into a schema/parser is allowed. Starters: `templates/env-schema.ts`, `templates/typed-parse.ts`.
5. **Type-check in CI** - `typecheck` / `check-types` / `type-check` / `test:types`, or any script invoking `tsc`/`tsgo`, must exist.
6. **Test emitted/runtime behaviour** - drive smoke, playwright, vitest/jest, or `node --test` against the running artifact. Types alone are not Done. Gate: `scripts/ts-runtime-gate.sh`.
7. **Exhaustive unions** - discriminated unions + `never` default. Oxlint `typescript/switch-exhaustiveness-check` in the product template; rule `typescript-exhaustive-switch`.
8. **`.d.ts` product vs library** - product public types must not expose `: any` (default rg scan includes `.d.ts`). Library host/plugin research may set `TS_RG_SKIP_DTS=1` or a single-line `ts-rg-allow`.
9. **Oxlint adoption** - product must ship `.oxlintrc.json` (or `oxlint.json`) encoding the four factory rules. Gate: `scripts/ts-oxlint-gate.sh` (config-only via `TS_OXLINT_CONFIG_ONLY=1`; live run pinned to `templates/oxlint.version` / `TS_OXLINT_VERSION`; `TS_OXLINT_BIN` / PATH / `node_modules/.bin` before `npx oxlint@$pin`; `TS_OXLINT_OFFLINE=1` refuses npx).

## Rules

- Discriminated unions + `never` exhaustiveness over optional-field bags
- `satisfies` / inference over widening annotations
- Schemas (or a typed parse function) before hand-rolled guards when the repo has a schema lib
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-typescript**. Selfcheck: `scripts/ts-kit-selfcheck.sh`.
