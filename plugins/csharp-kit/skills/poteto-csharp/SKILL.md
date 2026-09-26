---
name: poteto-csharp
description: Poteto-mode bar for C# products. Use for /poteto-mode on C# work, or when Dark asks for poteto bar on C#. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto C#

Apply `/poteto-mode` non-negotiables, then this leaf for C# libraries / services / CLIs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/csharp-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/csharp-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `CSHARP_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/csharp-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/csharp-analyzers-gate.sh <product-root>` exits 0.
5. `bash scripts/csharp-nullable-gate.sh <product-root>` exits 0.
6. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious nullable / concurrency / disposal constraints.
7. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
8. If Console / SQL concat / blocking-async touched: ILogger / parameterized command / await, `csharp-rg-allow` on the smell line when intentional.
9. Stricter product gates (live `dotnet format`, analyzers, nullable warnings-as-errors) override when present. Prove on the real artifact (tests / analyzers / format).
10. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- Formatter / analyzers / nullable wiring stay on
- Public API unchanged unless the goal is an API break
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (SQL / null / parse / net / async) before micro-opts
2. Delete dead path before adding
3. ILogger before Console.WriteLine
4. Parameterized command before SQL string concat
5. Measure (tests / analyzers / `dotnet format`) before further micro-opt

Load skill **csharp** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace Console.WriteLine with ILogger`, `Enable nullable in Directory.Build.props`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (C# only)

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
| PSR C# alignment | checklist: formatter (dotnet format / .editorconfig), Roslyn analyzers wiring, nullable enable, no unchecked Console.WriteLine / SQL concat / blocking-async |
| CI green | `csharp-rg-gate` + `csharp-hotpath-gate` + `csharp-fmt-gate` + `csharp-analyzers-gate` + `csharp-nullable-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. C# uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm C# passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
