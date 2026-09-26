---
name: poteto-vbnet
description: Poteto-mode bar for Visual Basic .NET products. Use for /poteto-mode on VB.NET work, or when Dark asks for poteto bar on VB.NET. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Visual Basic .NET

Apply `/poteto-mode` non-negotiables, then this leaf for VB.NET packs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/vbnet-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/vbnet-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `VBNET_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/vbnet-dotnet-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for unit contracts, or required allow markers.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If On Error Resume Next / Option Strict Off / Console.WriteLine-in-lib touched: replace with Try/Catch / Option Strict On / ILogger, or `vbnet-rg-allow` on the smell line when intentional.
7. Stricter product gates (live `dotnet build`, Option Strict project settings, Roslyn analyzers) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- dotnet / vbproj wiring stays on
- Public API contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (On Error Resume Next / Option Strict Off / Console.WriteLine-in-lib) before micro-opts
2. Delete dead path before adding
3. Try/Catch before On Error Resume Next
4. Option Strict On before Off
5. ILogger before Console in libs
6. Measure (`dotnet build` / smoke) before further micro-opt

Load skill **vbnet** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Ban On Error Resume Next in vbnet-kit`, `Require Option Strict On for VB.NET products`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `A1`-`An` or dates. Merged commit subjects stay history.

## Standing scorecard (Visual Basic .NET only)

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
| PSR VB.NET alignment | checklist: no On Error Resume Next, Option Strict On, no Console.WriteLine in libs, dotnet/vbproj wiring |
| CI green | `vbnet-rg-gate` + `vbnet-hotpath-gate` + `vbnet-dotnet-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`A1`-`An` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Visual Basic .NET uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm VB.NET passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
