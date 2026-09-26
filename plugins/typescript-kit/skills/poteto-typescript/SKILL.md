---
name: poteto-typescript
description: Poteto-mode bar for TypeScript products (Control-Glass and peers). Use for /poteto-mode on TS/React work, or when Dark asks for poteto bar on TypeScript. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto TypeScript

Apply `/poteto-mode` non-negotiables, then this leaf for TypeScript / Vite+React products.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/ts-rg-gate.sh <product-root>` exits 0 (product copy of pack script; scans `src`, else `lib`/`app`; override with `TS_RG_SRC`). Product mode scans `.d.ts`. Global `fetch` only (method `.fetch` allowed); whole-object `process.env` to a schema is OK.
2. `bash scripts/ts-strict-gate.sh <product-root>` exits 0 (strict via extends; typecheck aliases accepted).
3. `bash scripts/ts-runtime-gate.sh <product-root>` exits 0 (runtime/drive proof script present).
4. `bash scripts/ts-oxlint-gate.sh <product-root>` exits 0 (`.oxlintrc.json` encodes factory rules; live oxlint unless `TS_OXLINT_CONFIG_ONLY=1`).
5. Product `npm run typecheck` and `npm run lint` exit 0 when those scripts exist. Product oxlint matches `templates/oxlintrc.json` bar (`no-explicit-any`, `no-non-null-assertion`, `switch-exhaustiveness-check`).
6. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious external constraints (or required SAFETY markers for remaining assertions).
7. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
8. If DOM / `JSON.parse` / global fetch / URL / env touched: validate at the boundary into a named type or throw (see `templates/env-schema.ts` / `templates/typed-parse.ts`); no postfix `!` on the lookup. No `as unknown as` without `ts-rg-allow` rationale; no bare `@ts-expect-error`.
9. If discriminated unions touched: exhaustive `switch` with `never` default.
10. Stricter product gates (`verify-*`, `control-*`, visual-parity, anti-ai-ui, boundaries) override when present. Prove on the real artifact.
11. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- `strict` / `noImplicitAny` stay on
- Copy-contract / testids unchanged unless the goal is a product copy change
- Public feature `root` export contract unchanged unless the goal is an API break
- Soft Dark Glass / CONTROL-GLASS design tokens; no cyan accent invent

## Ranked bar

1. Trust boundary (external data / DOM / net) before micro-opts
2. Delete dead path before adding
3. Named domain types before assertion comments
4. Exhaustive unions before optional bags
5. Measure (bundle / profiler) before further micro-opt

Load skill **typescript** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Validate DOM root before createRoot`, `Ban non-null assertions on querySelector`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (TypeScript only)

Weighted product run sheet. Score each dim 0-10, then overall = sum(weight * score).

| Dimension | Weight |
|-----------|--------|
| 1. EXIT catch | 25% |
| 2. AI-slop | 10% |
| 3. Hot-path / perf | 15% |
| 4. Net / API trust | 15% |
| 5. Pack encode | 10% |
| 6. Residual | 5% |
| 7. Code amount | 10% |
| 8. Code quality | 5% |
| 9. Optimisations | 5% |

Standing extras (list separately; do not fold into the 100% weighted overall unless the run asks):

| Extra | /10 | Prove |
|-------|-----|-------|
| Handbook / strict alignment | checklist: strict+noImplicitAny, no unexplained any, no DOM `!`, boundary parse (JSON/global-fetch/URL/env; method `.fetch` OK), exhaustive unions, CI typecheck, runtime/drive proof, oxlint adoption |
| CI green | `ts-rg-gate` + `ts-strict-gate` + `ts-runtime-gate` + `ts-oxlint-gate` + product typecheck/lint PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. TS/UI uses this sheet plus existing Control-Glass gates. Kitchen docs stay docs-only.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
