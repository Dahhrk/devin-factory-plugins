---
name: poteto-mako
description: Poteto-mode bar for Mako products. Use for /poteto-mode on Mako work, or when Dark asks for poteto bar on Mako templates. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Mako

Apply `/poteto-mode` non-negotiables, then this leaf for Mako templates (`.mako` / HTML) and `mako` Python wiring.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/mako-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/mako-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `MAKO_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/mako-mako-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious trusted-HTML / legacy filter / include-path constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If disable_unicode / input_encoding / untrusted include / `|n` / empty filters / `module_directory` touched: utf-8 / static include / `|h` or page `expression_filter="h"` / no module_directory, or `mako-rg-allow` on the smell line when intentional.
7. Stricter product gates (live render + CSP + HTML sanitize) override when present. Prove on the real artifact (render / build).
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- mako wiring stays on for Mako template products
- Public template / route contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (unicode / include path / filter / module_directory / input) before micro-opts
2. Delete dead path before adding
3. `|h` / `expression_filter="h"` before `|n` / empty filters
4. Static `<%include>` before interpolated include paths
5. No `module_directory` before writable code-exec cache paths
6. utf-8 `input_encoding` before None / latin-1 / ascii / `disable_unicode`
7. Measure (pytest / render / build) before further micro-opt

Load skill **mako** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Prefer page expression_filter h`, `Ban module_directory cache paths`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Mako only)

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
| PSR Mako alignment | checklist: mako wiring, no disable_unicode/input_encoding footgun / untrusted include / `|n` raw / module_directory |
| CI green | `mako-rg-gate` + `mako-hotpath-gate` + `mako-mako-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Mako uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Mako passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
