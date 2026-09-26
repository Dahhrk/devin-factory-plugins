---
name: poteto-go
description: Poteto-mode bar for Go products. Use for /poteto-mode on Go work, or when Dark asks for poteto bar on Go. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Go

Apply `/poteto-mode` non-negotiables, then this leaf for Go modules / CLIs / services.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/go-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/go-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `GO_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/go-fmt-gate.sh <product-root> [paths...]` exits 0.
4. `bash scripts/go-vet-gate.sh <product-root> [./...]` exits 0.
5. `bash scripts/go-race-ci-gate.sh <product-root>` exits 0.
6. `bash scripts/go-golangci-gate.sh <product-root>` exits 0 (or `GO_GOLANGCI_GATE_SKIP=1` documented for tiny modules).
7. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious external constraints.
8. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
9. If goroutines / HTTP / files / exec touched: bound lifecycle, propagate ctx, close resources on all paths (see `templates/ctx_errgroup.go` / `templates/http_close.go`).
10. Stricter product gates (`golangci-lint`, verify-*) override when present. Prove on the real artifact (`go test`, race where supported).
11. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- `gofmt` / `go vet` stay clean
- Public module API unchanged unless the goal is an API break
- Race wiring in CI/Makefile stays on
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (ctx / errors / net / close) before micro-opts
2. Delete dead path before adding
3. Bound goroutines before more concurrency
4. Named domain errors before panic
5. Measure (`-bench`, pprof) before further micro-opt

Load skill **go** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Bound extension update check goroutine`, `Wire go test -race in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Go only)

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
| Effective Go / PSR alignment | checklist: gofmt, go vet, race wired, errors+%w, ctx cancel, bound goroutines, closes, no uncontrolled hooks |
| CI green | `go-rg-gate` + `go-hotpath-gate` + `go-fmt-gate` + `go-vet-gate` + `go-race-ci-gate` + `go-golangci-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Go uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Go passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
