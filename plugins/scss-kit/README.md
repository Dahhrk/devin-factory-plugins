# scss-kit

SCSS/Sass bar for the dark factory Cursor lane. Public research pilot: sass/dart-sass (MIT). One kit covers `.scss` and `.sass`.

| Surface | Path |
|---------|------|
| Skills | `skills/scss`, `skills/poteto-scss` |
| Rule | `rules/scss.mdc` (`**/*.{scss,sass,SCSS,SASS}`, not alwaysApply) |
| Tier 0 | `scripts/scss-rg-gate.sh` (!important abuse; @extend overuse; /deep/ or >>>; nesting depth >4; **single-walk** + file-level nest; requires **rg**) |
| Tier 0.5 | `scripts/scss-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `SCSS_RG_BUDGET_MS`) |
| Tier 1 | `scripts/scss-sass-gate.sh` (sass / dart-sass compile wiring / live) |
| Selfcheck | `scripts/scss-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/scss-gates.yml` |
| Boundaries | `templates/mixin_over_extend.scss`, `templates/flat_nesting.scss`, `templates/no_deep_combinator.scss`, `templates/specificity_over_important.scss` |

PSR SCSS encode (Programming Standards Reference): sass/dart-sass compile wiring; no `!important` abuse without allow; no `@extend` overuse without allow; no `/deep/` / `>>>` without allow; nesting depth ≤4. Primary authority: dart-sass compiler + Sass `@extend` complexity docs.

Compose with `/poteto-mode`. Tier 1 sass checks wiring (live `sass --version` when on PATH unless `SCSS_SASS_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/scss-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-scss` (SCSS/Sass stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`scss-rg-gate` walks the tree **once** (union of line smell patterns), classifies the hit set, then runs file-level nesting-depth. `scss-hotpath-gate` fails if that wall exceeds `SCSS_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `scss-rg-allow` with a short rationale. Nesting: `scss-rg-allow nest …` somewhere in the file. Prefer named boundaries from templates over scattered allows.

## Selfcheck

`bash scripts/scss-kit-selfcheck.sh` proves rg/hotpath/sass gates discriminate fixtures, single-walk encode, budget discrimination (`SCSS_RG_BUDGET_MS=1`), sass wiring bar, and template presence.
