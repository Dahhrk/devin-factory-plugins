# mako-kit

Mako bar for the dark factory Cursor lane. Public research pilot: sqlalchemy/mako (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/mako`, `skills/poteto-mako` |
| Rule | `rules/mako.mdc` (`**/*.{mako,html,py,pyi}`, not alwaysApply) |
| Tier 0 | `scripts/mako-rg-gate.sh` (disable_unicode / input_encoding footguns; untrusted `<%include>`; `${}` without filters / `\|n` raw; `module_directory` code-exec cache paths; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/mako-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `MAKO_RG_BUDGET_MS`) |
| Tier 1 | `scripts/mako-mako-gate.sh` (mako import / requirements / pyproject / CI wiring / live) |
| Selfcheck | `scripts/mako-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/mako-gates.yml` |
| Boundaries | `templates/page_html_filter.mako`, `templates/trusted_static_include.mako`, `templates/filtered_expression.mako`, `templates/lookup_no_module_dir.py` |

PSR Mako encode (Programming Standards Reference): do not use removed/legacy `disable_unicode` or risky `input_encoding` (None / latin-1 / ascii) footguns; do not `<%include file="...${...}..."/>` with untrusted interpolated paths; do not emit `${}` with `|n` / empty `default_filters` / `expression_filter="n"` (raw / without HTML filters); do not point `module_directory` at writable code-exec cache paths without allow. Primary authority: sqlalchemy/mako docs (filtering / unicode / syntax include / usage module_directory) — MIT.

Compose with `/poteto-mode`. Tier 1 checks mako wiring (live `import mako` when resolvable unless `MAKO_MAKO_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/mako-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-mako` (Mako stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`mako-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `mako-hotpath-gate` fails if that wall exceeds `MAKO_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `mako-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer `<%page expression_filter="h"/>` / `|h`. Prefer static `<%include file="header.mako"/>`. Prefer no `module_directory` (or a locked-down non-world-writable path with allow). Prefer utf-8 `input_encoding`; never `disable_unicode`.

## Selfcheck

`bash scripts/mako-kit-selfcheck.sh` proves rg/hotpath/mako gates discriminate fixtures, single-walk encode, budget discrimination (`MAKO_RG_BUDGET_MS=1`), mako wiring bar, and template presence.
