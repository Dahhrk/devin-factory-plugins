---
name: react
description: React PSR bar. react wiring, no dangerouslySetInnerHTML without sanitize, no findDOMNode, no ReactDOM.render (prefer createRoot). Use when reading or editing React JSX/TSX in a factory product.
paths: ["**/*.jsx", "**/*.tsx", "**/package.json", "**/.github/workflows/**"]
---

# React

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference React checks into product gates.

## PSR React (encoded)

1. **Agreed toolchain** — `react` / `react-dom` (`package.json` / `@vitejs/plugin-react` / CI). Gate: `scripts/react-react-gate.sh`. Product CI: `templates/github-workflows/react-gates.yml`.
2. **dangerouslySetInnerHTML without sanitize** — no raw `__html` without `DOMPurify.sanitize` / `sanitizeHtml` / `.sanitize(` on the same line (or allow). Prefer JSX children. Gate: `scripts/react-rg-gate.sh` (single-walk). Template: `templates/sanitize_inner_html.tsx`.
3. **findDOMNode** — no `findDOMNode` without allow. Prefer refs / callback refs. Gate: `scripts/react-rg-gate.sh`. Template: `templates/ref_not_find_dom_node.tsx`.
4. **ReactDOM.render** — no `ReactDOM.render(` without allow. Prefer `createRoot(...).render`. Gate: `scripts/react-rg-gate.sh`. Template: `templates/create_root_not_render.tsx`.
5. **Hot-path** — `scripts/react-hotpath-gate.sh` fails if rg-gate wall exceeds `REACT_RG_BUDGET_MS` (default 250ms).

## Rules

- `react-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-react**.
