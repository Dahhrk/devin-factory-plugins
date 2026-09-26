---
name: poteto-zig
description: Poteto-mode bar for Zig products. Use for /poteto-mode on Zig work, or when Dark asks for poteto bar on Zig. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Zig

Apply `/poteto-mode` non-negotiables, then this leaf for Zig packages / servers / CLIs / language tools.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/zig-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/zig-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `ZIG_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/zig-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/zig-build-test-gate.sh <product-root>` exits 0.
5. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious allocator / comptime / FFI constraints.
6. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
7. If `@panic` / `@trap` / `catch unreachable` / TODO touched: error union / `try`+`errdefer`, `zig-rg-allow` on the smell line when intentional.
8. Stricter product gates (live `zig fmt` / `zig build test`) override when present. Prove on the real artifact (tests).
9. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- zig fmt and zig build test wiring stay on
- Public API unchanged unless the goal is an API break
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (`@panic` / `@trap` / `catch unreachable` / TODO / input) before micro-opts
2. Delete dead path before adding
3. Error unions / `return error.` before `@panic` / `@trap` in libs
4. `try` / `errdefer` before `catch unreachable` on alloc and other fallible paths
5. Finish or track TODO/FIXME before leaving product comments
6. Measure (`zig build test`) before further micro-opt

Load skill **zig** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace catch unreachable with try`, `Wire zig build test in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Zig only)

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
| PSR Zig alignment | checklist: zig fmt, zig build test, no unchecked `@panic`/`@trap` / `catch unreachable` / TODO |
| CI green | `zig-rg-gate` + `zig-hotpath-gate` + `zig-fmt-gate` + `zig-build-test-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Zig uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Zig passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
