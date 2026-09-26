---
name: poteto-elixir
description: Poteto-mode bar for Elixir products. Use for /poteto-mode on Elixir work, or when Dark asks for poteto bar on Elixir. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Elixir

Apply `/poteto-mode` non-negotiables, then this leaf for Elixir packages / Phoenix apps / OTP services / Mix CLIs.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/elixir-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/elixir-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `ELIXIR_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/elixir-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/elixir-credo-gate.sh <product-root>` exits 0.
5. `bash scripts/elixir-dialyzer-gate.sh <product-root>` exits 0.
6. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious OTP / BEAM / dialyzer constraints.
7. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
8. If `String.to_atom` / SQL concat / `Process.sleep` touched: `String.to_existing_atom` / parameterized query / `send_after`, or `elixir-rg-allow` on the smell line when intentional.
9. Stricter product gates (live `mix format` / Credo / dialyzer) override when present. Prove on the real artifact (tests).
10. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- mix format, Credo, and dialyzer wiring stay on
- Public API unchanged unless the goal is an API break
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (`String.to_atom` / SQL concat / `Process.sleep` / input) before micro-opts
2. Delete dead path before adding
3. `String.to_existing_atom` / allowlisted atoms before `String.to_atom` on input
4. Parameterized queries before SQL string concat / interpolation
5. `Process.send_after` / receive before `Process.sleep` on hot paths
6. Measure (mix test / ExUnit) before further micro-opt

Load skill **elixir** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Replace String.to_atom with to_existing_atom`, `Wire Credo and dialyzer in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Elixir only)

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
| PSR Elixir alignment | checklist: mix format, Credo, dialyzer, no unchecked `String.to_atom` / SQL concat / `Process.sleep` |
| CI green | `elixir-rg-gate` + `elixir-hotpath-gate` + `elixir-fmt-gate` + `elixir-credo-gate` + `elixir-dialyzer-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Elixir uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Elixir passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
