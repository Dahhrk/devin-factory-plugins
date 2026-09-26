# pug-kit

Pug bar for the dark factory Cursor lane. Public research pilot: pugjs/pug (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/pug`, `skills/poteto-pug` |
| Rule | `rules/pug.mdc` (`**/*.{pug,Pug,jade,Jade}`, not alwaysApply) |
| Tier 0 | `scripts/pug-rg-gate.sh` (unescaped buffered XSS `!=` / `!{}`; include of untrusted interpolated paths; mixin injection `+#{…}`; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/pug-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `PUG_RG_BUDGET_MS`) |
| Tier 1 | `scripts/pug-pug-gate.sh` (pug package / config / CI wiring / live) |
| Selfcheck | `scripts/pug-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/pug-gates.yml` |
| Boundaries | `templates/buffered_escaped_output.pug`, `templates/trusted_static_include.pug`, `templates/static_mixin_call.pug` |

PSR Pug encode (Programming Standards Reference): pug wiring; no unescaped buffered / unescaped interpolation (`!=` / `!{}`) without allow (XSS); no `include` of untrusted interpolated paths (`include #{…}` / `include !{…}`); no mixin injection via dynamic mixin names (`+#{…}`). Primary authority: pugjs.org Code / Interpolation / Includes / Mixins cautions + pugjs/pug runtime escape.

Compose with `/poteto-mode`. Tier 1 pug checks wiring (live `node -e "require('pug')"` / `import('pug')` when resolvable unless `PUG_PUG_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/pug-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-pug` (Pug stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`pug-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `pug-hotpath-gate` fails if that wall exceeds `PUG_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `pug-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer buffered `=` / `#{…}` over `!=` / `!{…}`. Prefer static include paths. Prefer static mixin names (`+name`).

## Selfcheck

`bash scripts/pug-kit-selfcheck.sh` proves rg/hotpath/pug gates discriminate fixtures, single-walk encode, budget discrimination (`PUG_RG_BUDGET_MS=1`), pug wiring bar, and template presence.
