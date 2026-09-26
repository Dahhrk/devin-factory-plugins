---
name: go
description: Go PSR bar. gofmt, go vet, race in CI, errors/cancellation, bound goroutines, close resources, no uncontrolled globals. Use when reading or editing any .go in a factory product.
paths: ["**/*.go", "**/go.mod", "**/Makefile", "**/.golangci.yml"]
---

# Go

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Go checks into product gates.

## PSR Go (encoded)

1. **gofmt** — all Go sources formatted. Gate: `scripts/go-fmt-gate.sh`.
2. **go vet** — suspicious constructs clean. Gate: `scripts/go-vet-gate.sh`.
3. **go test + race** — unit/integration tests; race detector wired in Makefile or CI where supported. Gate: `scripts/go-race-ci-gate.sh` (wiring); run `go test -race` in product CI.
4. **Propagate errors and cancellation** — return `error`; wrap with `%w`; thread `context.Context`. Do not derive errgroups from `context.Background()` when a parent exists. Prefer enabling golangci `errcheck` + `bodyclose` (see templates).
5. **Bound goroutines** — every `go` has WaitGroup, errgroup, or cancel lifecycle. Gate: `scripts/go-rg-gate.sh` (single-walk).
6. **Close resources** — `defer resp.Body.Close()`, `defer cancel()`, file/conn Close on all paths. Product golangci `bodyclose` is the typed bar. Starter: `templates/http_close.go`.
7. **Avoid uncontrolled globals** — no exported package-level `var Hook = func...` without allow + rationale. Prefer constructor params. Gate: `scripts/go-rg-gate.sh`.
8. **Hot-path** — `scripts/go-hotpath-gate.sh` fails if rg-gate wall exceeds `GO_RG_BUDGET_MS` (default 250ms).
9. **golangci bodyclose + errcheck** — typed close/error bar. Gate: `scripts/go-golangci-gate.sh`; starter config in `templates/golangci/golangci.yml`.

## Rules

- Sentinel `var ErrX = errors.New(...)` is fine; mutable hooks are not
- `context.WithTimeout` / `WithCancel` at API and command boundaries
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-go**.
