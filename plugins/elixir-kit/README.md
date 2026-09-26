# elixir-kit

Elixir bar for the dark factory Cursor lane. Public research pilot: phoenixframework/phoenix (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/elixir`, `skills/poteto-elixir` |
| Rule | `rules/elixir.mdc` (`**/*.{ex,exs}`, not alwaysApply) |
| Tier 0 | `scripts/elixir-rg-gate.sh` (`String.to_atom`; SQL concat/`#{}`; `Process.sleep`; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/elixir-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `ELIXIR_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/elixir-fmt-gate.sh` (mix format wiring / live) |
| Tier 1 | `scripts/elixir-credo-gate.sh` (Credo wiring) |
| Tier 1 | `scripts/elixir-dialyzer-gate.sh` (dialyzer / dialyxir wiring) |
| Selfcheck | `scripts/elixir-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/elixir-gates.yml` |
| Boundaries | `templates/safe_atom.ex`, `templates/prepared_query.ex` |
| Format / Credo starters | `templates/.formatter.exs`, `templates/.credo.exs` |

PSR Elixir encode (Programming Standards Reference): mix format; Credo; dialyzer wiring; no `String.to_atom` on input without allow; no SQL string concat / `#{}` interpolation without allow; no `Process.sleep` on hot paths without allow. Primary authority: Elixir language docs and hexpm tooling (`mix format`, Credo, dialyxir).

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live `mix format --check-formatted` when on PATH unless `ELIXIR_FMT_CONFIG_ONLY=1`). Credo and dialyzer gates check config / deps / CI wiring.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/elixir-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-elixir` (Elixir stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`elixir-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `elixir-hotpath-gate` fails if that wall exceeds `ELIXIR_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and phoenixframework/phoenix `lib/` under default budget.

### Escape

Line marker `elixir-rg-allow` with a short rationale. Prefer named boundaries from `templates/safe_atom.ex` / `templates/prepared_query.ex` over scattered allows.

## Selfcheck

`bash scripts/elixir-kit-selfcheck.sh` proves rg/hotpath/fmt/credo/dialyzer gates discriminate fixtures, single-walk encode, budget discrimination (`ELIXIR_RG_BUDGET_MS=1`), and template presence.
