# just-kit

Just bar for the dark factory Cursor lane. Public research pilot: casey/just (CC0-1.0 / custom permissive) command runner (`Shebang Recipes`, `Script Recipes`, `Dotenv Settings`, `Export`, `Imports`, `Modules` in README).

| Surface | Path |
|---------|------|
| Skills | `skills/just`, `skills/poteto-just` |
| Rule | `rules/just.mdc` (`**/justfile`, `**/Justfile`, `**/.justfile`, `**/*.just`, not alwaysApply) |
| Tier 0 | `scripts/just-rg-gate.sh` (unchecked [script]/shebang; dotenv secrets in recipes; export of secrets; include of untrusted path; curl\|bash; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/just-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `JUST_RG_BUDGET_MS`) |
| Tier 1 | `scripts/just-just-gate.sh` (justfile / *.just / CI just wiring / live `just --version` when resolvable) |
| Selfcheck | `scripts/just-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/just-gates.yml` |
| Boundaries | `templates/no_script_shebang.just`, `templates/no_dotenv_secrets.just`, `templates/no_export_secrets.just`, `templates/trusted_static_import.just`, `templates/no_curl_bash.just` |

PSR Just encode (Programming Standards Reference): prefer line recipes over unchecked `[script]` / shebang recipes; never load dotenv secrets into recipes (`set dotenv-*`); never `export` secret-named vars / `[env(SECRET,...)]`; never `import` / `mod` of untrusted / interpolated / `~/` / absolute path (prefer static relative `import 'rules.just'` / `mod foo`); never `curl|bash` / `wget|sh` recipes. Primary authority: casey/just README — CC0-1.0 (public domain dedication + fallback license).

Compose with `/poteto-mode`. Tier 1 checks just wiring (live `just --version` when resolvable unless `JUST_JUST_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/just-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-just` (Just / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`just-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `just-hotpath-gate` fails if that wall exceeds `JUST_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `just-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer line recipes with `set -euxo pipefail` only when a shebang is intentional and allowed. Prefer CI/OIDC secrets over dotenv. Prefer static relative imports. Prefer checksum install over pipe-to-shell.

## Selfcheck

`bash scripts/just-kit-selfcheck.sh` proves rg/hotpath/just gates discriminate fixtures, single-walk encode, budget discrimination (`JUST_RG_BUDGET_MS=1`), just wiring bar, and template presence.
