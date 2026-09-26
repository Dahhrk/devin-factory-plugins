# tailwind-kit

Tailwind CSS bar for the dark factory Cursor lane. Public research pilot: tailwindlabs/tailwindcss (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/tailwind`, `skills/poteto-tailwind` |
| Rule | `rules/tailwind.mdc` (`**/*.{css,html,js,jsx,ts,tsx,vue,svelte,astro,mdx}` + `tailwind.config.*`, not alwaysApply) |
| Tier 0 | `scripts/tailwind-rg-gate.sh` (`@apply` overuse; arbitrary-value sprawl; safelist abuse / `@source inline`; content-path miss / purge footguns; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/tailwind-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `TAILWIND_RG_BUDGET_MS`) |
| Tier 1 | `scripts/tailwind-tailwind-gate.sh` (tailwindcss package / config / CI wiring / live) |
| Selfcheck | `scripts/tailwind-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/tailwind-gates.yml` |
| Boundaries | `templates/utility_over_apply.html`, `templates/design_tokens_not_arbitrary.html`, `templates/content_paths_complete.js`, `templates/no_safelist_abuse.js` |

PSR Tailwind encode (Programming Standards Reference): tailwindcss wiring; no `@apply` overuse (prefer utilities / components); no arbitrary-value sprawl (`w-[…]` / `[prop:…]`; prefer design tokens); no safelist abuse (`safelist:` / `@source inline(…)` blanket); no content-path miss / purge footguns (empty `content: []`, dynamic class concat). Primary authority: Tailwind docs (reusing styles / content configuration) + tailwindlabs/tailwindcss oxide extractor + `@source` / compat safelist surfaces.

Compose with `/poteto-mode`. Tier 1 checks wiring (live `import('tailwindcss')` when resolvable unless `TAILWIND_TAILWIND_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/tailwind-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-tailwind` (Tailwind stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`tailwind-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `tailwind-hotpath-gate` fails if that wall exceeds `TAILWIND_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `tailwind-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer utilities / components over `@apply`. Prefer theme tokens over arbitrary values. Prefer correct `content` / `@source` paths over safelist / `@source inline`. Prefer complete class strings over dynamic concat.

## Selfcheck

`bash scripts/tailwind-kit-selfcheck.sh` proves rg/hotpath/tailwind gates discriminate fixtures, single-walk encode, budget discrimination (`TAILWIND_RG_BUDGET_MS=1`), tailwindcss wiring bar, and template presence.
