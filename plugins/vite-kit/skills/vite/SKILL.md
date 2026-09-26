---
name: vite
description: Vite PSR bar. vite wiring, no server.fs.strict:false, no parent-escape server.fs.allow, no loadEnv empty-prefix all-env dump. Use when reading or editing vite.config / Vite product tooling.
paths: ["**/vite.config.*", "**/vitest.config.*", "**/package.json", "**/.github/workflows/**"]
---

# Vite

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Vite checks into product gates.

## PSR Vite (encoded)

1. **Agreed toolchain** — `vite` (`package.json` `"vite":` / `vite.config.*` / CI `vite build|dev|preview`). Gate: `scripts/vite-vite-gate.sh`. Product CI: `templates/github-workflows/vite-gates.yml`.
2. **server.fs.strict:false** — do not disable FS restriction (default true since Vite 2.7). Gate: `scripts/vite-rg-gate.sh` (single-walk). Template: `templates/fs_strict_default.ts`.
3. **server.fs.allow parent escape** — no `allow: ['..']` without allow. Prefer `searchForWorkspaceRoot` / explicit dirs. Gate: `scripts/vite-rg-gate.sh`. Template: `templates/fs_allow_workspace.ts`.
4. **loadEnv empty-prefix** — no `loadEnv(mode, dir, '')` without allow (loads all env). Prefer default `VITE_` filter. Gate: `scripts/vite-rg-gate.sh`. Template: `templates/loadenv_vite_prefix.ts`.
5. **Hot-path** — `scripts/vite-hotpath-gate.sh` fails if rg-gate wall exceeds `VITE_RG_BUDGET_MS` (default 250ms).

## Rules

- `vite-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-vite**.
