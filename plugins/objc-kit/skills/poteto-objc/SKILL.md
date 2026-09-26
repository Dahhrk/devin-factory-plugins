---
name: poteto-objc
description: Poteto-mode bar for Objective-C products. Use for /poteto-mode on ObjC work, or when Dark asks for poteto bar on Objective-C. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Objective-C

Apply `/poteto-mode` non-negotiables, then this leaf for Cocoa / GNUstep / ARC ObjC packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/objc-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/objc-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `OBJC_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/objc-fmt-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for CF bridge contracts, or required allow markers.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If NSLog / performSelector / retain|release|autorelease touched: replace with os_log / typed call / ARC, or `objc-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `clang-format --dry-run -Werror`, `-Warc-performSelector-leaks` as error) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- clang-format wiring stays on
- Public header / API contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (NSLog / performSelector / MRC) before micro-opts
2. Delete dead path before adding
3. Typed selectors / blocks before performSelector:
4. ARC before manual retain/release/autorelease
5. os_log / injected logger before NSLog in libs
6. Measure (xcodebuild / clang / smoke) before further micro-opt

Load skill **objc** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban NSLog in objc-kit`, `Require clang-format for ObjC products`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `A1`-`An` or dates. Merged commit subjects stay history.

## Standing scorecard (Objective-C only)

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
| PSR ObjC alignment | checklist: clang-format, ARC (no manual retain/release/autorelease), no NSLog in libs, no performSelector: |
| CI green | `objc-rg-gate` + `objc-hotpath-gate` + `objc-fmt-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`A1`-`An` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Objective-C uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm ObjC passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
