# mdx-kit

MDX bar for the dark factory Cursor lane. Public research pilot: mdx-js/mdx (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/mdx`, `skills/poteto-mdx` |
| Rule | `rules/mdx.mdc` (`**/*.{mdx,MDX}`, not alwaysApply) |
| Tier 0 | `scripts/mdx-rg-gate.sh` (dangerouslySetInnerHTML; untrusted evaluate; rehype-raw without sanitize; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/mdx-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `MDX_RG_BUDGET_MS`) |
| Tier 1 | `scripts/mdx-mdx-gate.sh` (@mdx-js package / config / CI wiring / live) |
| Selfcheck | `scripts/mdx-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/mdx-gates.yml` |
| Boundaries | `templates/no_dangerously_set_inner_html.mdx`, `templates/trusted_static_mdx_import.mjs`, `templates/rehype_raw_with_sanitize.mjs` |

PSR MDX encode (Programming Standards Reference): @mdx-js/mdx wiring; no raw HTML injection via `dangerouslySetInnerHTML` without allow; no untrusted JSX via `evaluate`/`evaluateSync` of dynamic MDX without allow; no `rehype-raw` / `rehypeRaw` without `rehype-sanitize` / `rehypeSanitize`. Primary authority: mdx-js/mdx Security chapter (MDX is a programming language; do not compile untrusted author input).

Compose with `/poteto-mode`. Tier 1 mdx checks wiring (live `node -e "import('@mdx-js/mdx')"` when resolvable unless `MDX_MDX_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/mdx-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-mdx` (MDX stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`mdx-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `mdx-hotpath-gate` fails if that wall exceeds `MDX_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `mdx-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. `rehype-raw` with `rehype-sanitize` / `rehypeSanitize` in the same file passes without allow. Prefer static `.mdx` imports over runtime `evaluate`.

## Selfcheck

`bash scripts/mdx-kit-selfcheck.sh` proves rg/hotpath/mdx gates discriminate fixtures, single-walk encode, budget discrimination (`MDX_RG_BUDGET_MS=1`), mdx wiring bar, and template presence.
