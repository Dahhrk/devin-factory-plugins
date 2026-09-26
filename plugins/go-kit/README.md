# go-kit

Go bar for the dark factory Cursor lane. Public research pilot: cli/cli (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/go`, `skills/poteto-go` |
| Rule | `rules/go.mdc` (`**/*.go`, not alwaysApply) |
| Tier 0 | `scripts/go-rg-gate.sh` (func hooks / bare `go` / ioutil / panic / errgroup+Background; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/go-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `GO_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/go-fmt-gate.sh` + `scripts/go-vet-gate.sh` |
| Tier 1 | `scripts/go-race-ci-gate.sh` (Makefile or CI must wire `-race`) |
| Tier 1b | `scripts/go-golangci-gate.sh` (`.golangci.yml` enables `bodyclose` + `errcheck`) |
| Selfcheck | `scripts/go-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/go-gates.yml` + `templates/golangci/golangci.yml` |
| Boundaries | `templates/ctx_errgroup.go`, `templates/http_close.go` |

PSR Go encode (Programming Standards Reference): gofmt, go vet, go test and race testing where supported; propagate errors and cancellation; bound goroutines; close resources; avoid uncontrolled globals. Primary authority: Go specification, Effective Go, module docs.

Compose with `/poteto-mode`. Tier 1b requires bodyclose + errcheck in product golangci; staticcheck and peers remain product choice.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/go-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-go` (Go stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`go-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `go-hotpath-gate` fails if that wall exceeds `GO_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and cli/cli under default budget.

### Escape

Line marker `go-rg-allow` with a short rationale. Prefer named boundaries from `templates/ctx_errgroup.go` / `templates/http_close.go` over scattered allows.

## Selfcheck

`bash scripts/go-kit-selfcheck.sh` proves rg/hotpath/fmt/race-ci/golangci gates discriminate fixtures, single-walk encode, budget discrimination (`GO_RG_BUDGET_MS=1`), and template presence.
