# vite-kit

Vite bar for the dark factory Cursor lane. Public research pilot: vitejs/vite (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/vite`, `skills/poteto-vite` |
| Rule | `rules/vite.mdc` (`**/vite.config.*`, not alwaysApply) |
| Tier 0 | `scripts/vite-rg-gate.sh` (fs.strict:false; allow:['..']; loadEnv empty-prefix; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/vite-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `VITE_RG_BUDGET_MS`) |
| Tier 1 | `scripts/vite-vite-gate.sh` (vite package / vite.config.* / CI vite build-dev-preview wiring / live) |
| Selfcheck | `scripts/vite-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/vite-gates.yml` |
| Boundaries | `templates/fs_strict_default.ts`, `templates/fs_allow_workspace.ts`, `templates/loadenv_vite_prefix.ts` |

PSR Vite encode (Programming Standards Reference): vite wiring; no `server.fs.strict: false` without allow; no `allow: ['..']` without allow; no `loadEnv(..., '')` empty-prefix without allow. Primary authority: vitejs/vite docs (MIT) — server.fs.strict default true, allow:['..'] example, loadEnv empty third arg footgun.

Compose with `/poteto-mode`. Tier 1 vite checks wiring (live `vite --version` when on PATH unless `VITE_VITE_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/vite-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-vite` (Vite stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`vite-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `vite-hotpath-gate` fails if that wall exceeds `VITE_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `vite-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows.

## Selfcheck

`bash scripts/vite-kit-selfcheck.sh` proves rg/hotpath/vite gates discriminate fixtures, single-walk encode, budget discrimination (`VITE_RG_BUDGET_MS=1`), vite wiring bar, and template presence.
