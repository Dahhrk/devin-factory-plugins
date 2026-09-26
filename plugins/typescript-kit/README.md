# typescript-kit

TypeScript bar for the dark factory Cursor lane. Pilot product: Control-Glass.

| Surface | Path |
|---------|------|
| Skills | `skills/typescript`, `skills/poteto-typescript` |
| Rule | `rules/typescript.mdc` (`**/*.{ts,tsx}`, not alwaysApply) |
| Tier 0 | `scripts/ts-rg-gate.sh` (any / as any / @ts-ignore / DOM `!` / bare JSON.parse) |
| Tier 0.5 | `scripts/ts-strict-gate.sh` (strict + noImplicitAny in app tsconfig; typecheck script present) |
| Product CI | `templates/github-workflows/ts-gates.yml` (Tier 0+0.5; compose with product oxlint/tsc) |

PSR TypeScript encode (Programming Standards Reference): handbook/compiler options + ECMAScript semantics; enable strict checking; avoid unexplained any and assertions; validate external data at runtime; type-check in CI; test emitted/runtime behaviour.

Compose with `/poteto-mode` and pstack `typescript-best-practices`. Does not replace product oxlint anti-slop or Control-Glass UI gates.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/typescript-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-typescript` (TS stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).
