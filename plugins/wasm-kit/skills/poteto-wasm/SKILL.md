---
name: poteto-wasm
description: Poteto-mode bar for WebAssembly products. Use for /poteto-mode on Wasm work, or when Dark asks for poteto bar on Wasm. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto WebAssembly

Apply `/poteto-mode` non-negotiables, then this leaf for Wasm packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/wasm-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/wasm-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `WASM_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/wasm-tools-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for unit contracts, required `;;` grow bounds, or required allow markers.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If debug wat / memory.grow / host-eval import touched: remove debug, add `;;` bound comment (or allow), or replace eval import with a typed host API + `wasm-rg-allow` when intentional.
7. Stricter product gates (live `wat2wasm` / `wasm-tools validate`, wasmtime smoke) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- wat / wasm tooling wiring stays on
- Public API contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (wat hygiene / memory.grow comment / host-eval import) before micro-opts
2. Delete dead path before adding
3. Documented `memory.grow` bound before silent unbounded grow
4. Typed host import before eval-shaped import
5. Measure (`wat2wasm` / validate / smoke) before further micro-opt

Load skill **wasm** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban unbounded memory.grow in wasm-kit`, `Reject imported host eval in wat modules`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `A1`-`An` or dates. Merged commit subjects stay history.

## Standing scorecard (WebAssembly only)

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
| PSR Wasm alignment | checklist: wat hygiene, memory.grow with `;;` bound, no host-eval import, wat/wasm tooling wiring |
| CI green | `wasm-rg-gate` + `wasm-hotpath-gate` + `wasm-tools-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`A1`-`An` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. WebAssembly uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Wasm passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
