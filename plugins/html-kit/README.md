# html-kit

HTML bar for the dark factory Cursor lane. Public research pilot: htmlhint/HTMLHint (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/html`, `skills/poteto-html` |
| Rule | `rules/html.mdc` (`**/*.{html,htm,HTML,HTM}`, not alwaysApply) |
| Tier 0 | `scripts/html-rg-gate.sh` (missing alt; inline JS/CSS; external script without integrity; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/html-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `HTML_RG_BUDGET_MS`) |
| Tier 1 | `scripts/html-htmlhint-gate.sh` (htmlhint lint wiring / live; requires alt-require + inline-script-disabled + inline-style-disabled) |
| Selfcheck | `scripts/html-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/html-gates.yml` |
| Boundaries | `templates/accessible_img.html`, `templates/external_script_sri.html` |
| Lint starter | `templates/.htmlhintrc` |

PSR HTML encode (Programming Standards Reference): htmlhint lint; no missing `alt` on `<img>` without allow; no inline JS/CSS smells without allow; no external `<script src="https?://…">` without `integrity=` where relevant without allow. Primary authority: HTMLHint rules (alt-require, inline-script-disabled, inline-style-disabled) and SRI guidance.

Compose with `/poteto-mode`. Tier 1 htmlhint checks wiring (live `htmlhint` when on PATH unless `HTML_HTMLHINT_CONFIG_ONLY=1`). Config must keep alt-require, inline-script-disabled, and inline-style-disabled enabled.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/html-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-html` (HTML stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`html-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `html-hotpath-gate` fails if that wall exceeds `HTML_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and HTMLHint research fixtures under default budget.

### Escape

Line marker `html-rg-allow` with a short rationale. Prefer named boundaries from `templates/accessible_img.html` / `templates/external_script_sri.html` over scattered allows.

## Selfcheck

`bash scripts/html-kit-selfcheck.sh` proves rg/hotpath/htmlhint gates discriminate fixtures, single-walk encode, budget discrimination (`HTML_RG_BUDGET_MS=1`), PSR htmlhint rules bar, and template presence.
