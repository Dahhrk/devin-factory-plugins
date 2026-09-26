# astro-kit

Astro bar for the dark factory Cursor lane. Public research pilot: withastro/astro (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/astro`, `skills/poteto-astro` |
| Rule | `rules/astro.mdc` (`**/*.astro`, not alwaysApply) |
| Tier 0 | `scripts/astro-rg-gate.sh` (client:load abuse; set:html without sanitize; define:vars XSS; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/astro-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `ASTRO_RG_BUDGET_MS`) |
| Tier 1 | `scripts/astro-astro-gate.sh` (astro package / config / CI check-build wiring / live) |
| Selfcheck | `scripts/astro-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/astro-gates.yml` |
| Boundaries | `templates/client_visible_not_load.astro`, `templates/set_html_sanitized.astro`, `templates/data_attrs_not_define_vars.astro` |

PSR Astro encode (Programming Standards Reference): astro check/build wiring; no `client:load` abuse without allow; no `set:html` without sanitize (or allow); no `define:vars` without allow (XSS / inline-script smell; prefer `data-*`). Primary authority: withastro/astro runtime (`defineScriptVars`, `set:html`) + island client directives.

Compose with `/poteto-mode`. Tier 1 astro checks wiring (live `astro --version` when on PATH unless `ASTRO_ASTRO_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/astro-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-astro` (Astro stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`astro-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `astro-hotpath-gate` fails if that wall exceeds `ASTRO_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `astro-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. `set:html={DOMPurify.sanitize(...)}` / `sanitizeHtml(...)` / `.sanitize(...)` on the same line passes without allow.

## Selfcheck

`bash scripts/astro-kit-selfcheck.sh` proves rg/hotpath/astro gates discriminate fixtures, single-walk encode, budget discrimination (`ASTRO_RG_BUDGET_MS=1`), astro wiring bar, and template presence.
