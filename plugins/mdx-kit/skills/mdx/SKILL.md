---
name: mdx
description: PSR MDX encode for product MDX content and pipelines. Use when editing .mdx or @mdx-js / remark / rehype wiring.
disable-model-invocation: false
---

# MDX

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference MDX checks into product gates.

## PSR MDX (encoded)

1. **Agreed toolchain** — `@mdx-js/mdx` (or `@mdx-js/rollup` / `@mdx-js/loader` / `@next/mdx`) in `package.json` / mdx config / CI. Gate: `scripts/mdx-mdx-gate.sh`. Product CI: `templates/github-workflows/mdx-gates.yml`.
2. **Raw HTML injection** — no `dangerouslySetInnerHTML` without allow. Prefer MDX/JSX children or sanitized markdown (`react-markdown` + `rehype-sanitize`). Gate: `scripts/mdx-rg-gate.sh` (single-walk). Template: `templates/no_dangerously_set_inner_html.mdx`.
3. **Untrusted JSX in MDX** — no `evaluate` / `evaluateSync` of dynamic / user-controlled MDX without allow. Prefer static `.mdx` imports from trusted authors (MDX is a programming language). Gate: `scripts/mdx-rg-gate.sh`. Template: `templates/trusted_static_mdx_import.mjs`.
4. **rehype/remark plugin footguns** — no `rehype-raw` / `rehypeRaw` without `rehype-sanitize` / `rehypeSanitize` in the same file. Gate: `scripts/mdx-rg-gate.sh`. Template: `templates/rehype_raw_with_sanitize.mjs`.
5. **Hot-path** — `scripts/mdx-hotpath-gate.sh` fails if rg-gate wall exceeds `MDX_RG_BUDGET_MS` (default 250ms).

## Rules

- `mdx-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-mdx**.
