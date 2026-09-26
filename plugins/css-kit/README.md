# css-kit

CSS bar for the dark factory Cursor lane. Public research pilot: stylelint/stylelint (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/css`, `skills/poteto-css` |
| Rule | `rules/css.mdc` (`**/*.{css,CSS}`, not alwaysApply) |
| Tier 0 | `scripts/css-rg-gate.sh` (!important abuse; universal selector hotpath; expression()/behavior IE smells; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/css-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `CSS_RG_BUDGET_MS`) |
| Tier 1 | `scripts/css-stylelint-gate.sh` (stylelint lint wiring / live; requires declaration-no-important + selector-max-universal) |
| Selfcheck | `scripts/css-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/css-gates.yml` |
| Boundaries | `templates/specificity_over_important.css`, `templates/scoped_reset.css` |
| Lint starter | `templates/.stylelintrc.json` |

PSR CSS encode (Programming Standards Reference): stylelint lint; no `!important` abuse without allow; no universal selector `*` hotpath without allow; no `expression()` / `behavior:` IE smells without allow. Primary authority: stylelint rules (`declaration-no-important`, `selector-max-universal`) and IE legacy trust bar.

Compose with `/poteto-mode`. Tier 1 stylelint checks wiring (live `stylelint` when on PATH unless `CSS_STYLELINT_CONFIG_ONLY=1`). Config must keep declaration-no-important and selector-max-universal enabled.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/css-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-css` (CSS stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`css-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `css-hotpath-gate` fails if that wall exceeds `CSS_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and stylelint research fixtures under default budget.

### Escape

Line marker `css-rg-allow` with a short rationale. Prefer named boundaries from `templates/specificity_over_important.css` / `templates/scoped_reset.css` over scattered allows.

## Selfcheck

`bash scripts/css-kit-selfcheck.sh` proves rg/hotpath/stylelint gates discriminate fixtures, single-walk encode, budget discrimination (`CSS_RG_BUDGET_MS=1`), PSR stylelint rules bar, and template presence.
