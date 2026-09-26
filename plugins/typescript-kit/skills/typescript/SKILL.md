---
name: typescript
description: TypeScript PSR bar. Strict checking (extends-aware), no unexplained any/assertions/double-assertion, described @ts-expect-error, runtime boundary validation, CI typecheck aliases, emitted/runtime proof. Use when reading or editing any .ts or .tsx in a factory product.
paths: ["**/*.ts", "**/*.tsx", "**/tsconfig*.json"]
---

# TypeScript

Apply pstack **principle-type-system-discipline** and **typescript-best-practices** first. This skill encodes Programming Standards Reference TypeScript checks into product gates.

## PSR TypeScript (encoded)

1. **Handbook + compiler options** - follow TypeScript handbook idioms; product `tsconfig` is the contract.
2. **Strict checking** - `strict: true` on the app config or an `extends` parent. Gate: `scripts/ts-strict-gate.sh` (walks extends; accepts tsconfig.app/json/base/build/types).
3. **Avoid unexplained any and assertions** - ban `: any`, `as any`, `as unknown as`, bare `@ts-ignore` / `@ts-nocheck`, and `@ts-expect-error` without a trailing description. Prefer `unknown` + parse. Non-null `!` on external lookups is an unexplained assertion. Gate: `scripts/ts-rg-gate.sh`; product should also set oxlint `typescript/no-explicit-any` and `typescript/no-non-null-assertion`.
4. **Validate external data at runtime** - DOM nodes, `JSON.parse`, fetch/URL/env cross into named domain types at the boundary. No postfix `!` on `getElementById` / `querySelector*`.
5. **Type-check in CI** - `typecheck` / `check-types` / `type-check` / `test:types`, or any script invoking `tsc`/`tsgo`, must exist.
6. **Test emitted/runtime behaviour** - drive smoke, playwright, or unit against the running artifact. Types alone are not Done.

## Rules

- Discriminated unions + `never` exhaustiveness over optional-field bags
- `satisfies` / inference over widening annotations
- Schemas (or a typed parse function) before hand-rolled guards when the repo has a schema lib
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-typescript**. Selfcheck: `scripts/ts-kit-selfcheck.sh`.
