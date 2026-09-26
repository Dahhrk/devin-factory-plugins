# react-kit

React bar for the dark factory Cursor lane. Public research pilot: facebook/react (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/react`, `skills/poteto-react` |
| Rule | `rules/react.mdc` (`**/*.{jsx,tsx}`, not alwaysApply) |
| Tier 0 | `scripts/react-rg-gate.sh` (dangerouslySetInnerHTML without sanitize; findDOMNode; ReactDOM.render; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/react-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `REACT_RG_BUDGET_MS`) |
| Tier 1 | `scripts/react-react-gate.sh` (react / react-dom / @vitejs/plugin-react / CI wiring / live) |
| Selfcheck | `scripts/react-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/react-gates.yml` |
| Boundaries | `templates/sanitize_inner_html.tsx`, `templates/ref_not_find_dom_node.tsx`, `templates/create_root_not_render.tsx` |

PSR React encode (Programming Standards Reference): react wiring; no `dangerouslySetInnerHTML` without sanitize (or allow); no `findDOMNode` without allow; no `ReactDOM.render` without allow (prefer `createRoot`). Primary authority: facebook/react fixtures (MIT) — SSR Chrome dangerouslySetInnerHTML, dom hydration findDOMNode, packaging ReactDOM.render.

Compose with `/poteto-mode`. Tier 1 react checks wiring (live `require.resolve('react')` when node resolves unless `REACT_REACT_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/react-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-react` (React stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`react-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `react-hotpath-gate` fails if that wall exceeds `REACT_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `react-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. `dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(...) }}` / `sanitizeHtml(...)` / `.sanitize(...)` on the same line passes without allow.

## Selfcheck

`bash scripts/react-kit-selfcheck.sh` proves rg/hotpath/react gates discriminate fixtures, single-walk encode, budget discrimination (`REACT_RG_BUDGET_MS=1`), react wiring bar, and template presence.
