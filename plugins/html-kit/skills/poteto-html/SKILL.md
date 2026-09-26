---
name: poteto-html
description: Poteto-mode bar for HTML products. Use for /poteto-mode on HTML work, or when Dark asks for poteto bar on HTML. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto HTML

Apply `/poteto-mode` non-negotiables, then this leaf for HTML pages / templates / static sites / email-ish markup packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/html-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/html-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `HTML_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/html-htmlhint-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious a11y / CSP / SRI constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If missing alt / inline JS/CSS / script-without-integrity touched: alt or aria-hidden / external assets / SRI, or `html-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `htmlhint` with full rule set) override when present. Prove on the real artifact (a11y / visual checks).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- htmlhint lint wiring stays on with alt-require, inline-script-disabled, and inline-style-disabled enabled
- Public markup / template contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (missing alt / inline JS/CSS / script without integrity / input) before micro-opts
2. Delete dead path before adding
3. Explicit alt (or decorative aria-hidden) before bare `<img>`
4. External CSS/JS before inline style / on* / javascript:
5. SRI `integrity=` before bare CDN `<script src="https://…">`
6. Measure (a11y / visual) before further micro-opt

Load skill **html** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Require img alt attributes`, `Wire htmlhint alt-require in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (HTML only)

Weighted product run sheet. Score each dim 0-10, then overall = sum(weight * score).

| Dimension | Weight |
|-----------|--------|
| 1. EXIT catch | 25% |
| 2. AI-slop | 10% |
| 3. Hot-path / perf | 15% |
| 4. Net / API trust | 15% |
| 5. Pack encode | 10% |
| 6. Residual | 5% |
| 7. Code amount | 10% |
| 8. Code quality | 5% |
| 9. Optimisations | 5% |

Standing extras (list separately; do not fold into the 100% weighted overall unless the run asks):

| Extra | /10 | Prove |
|-------|-----|-------|
| PSR HTML alignment | checklist: htmlhint lint, alt-require, inline-script-disabled, inline-style-disabled, no unchecked missing alt / inline JS/CSS / script-without-integrity |
| CI green | `html-rg-gate` + `html-hotpath-gate` + `html-htmlhint-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. HTML uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm HTML passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
