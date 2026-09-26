# zig-kit

Zig bar for the dark factory Cursor lane. Public research pilot: zigtools/zls (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/zig`, `skills/poteto-zig` |
| Rule | `rules/zig.mdc` (`**/*.zig`, not alwaysApply) |
| Tier 0 | `scripts/zig-rg-gate.sh` (`@panic`/`@trap`; `catch unreachable`; TODO/FIXME; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/zig-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `ZIG_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/zig-fmt-gate.sh` (zig fmt wiring / live) |
| Tier 1 | `scripts/zig-build-test-gate.sh` (zig build test wiring) |
| Selfcheck | `scripts/zig-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/zig-gates.yml` |
| Boundaries | `templates/try_alloc.zig`, `templates/error_return.zig` |

PSR Zig encode (Programming Standards Reference): zig fmt; zig build test; no `@panic`/`@trap` in libs without allow; no `catch unreachable` (unchecked alloc / ignored errors) without allow; no TODO/FIXME without allow. Primary authority: Zig language reference and ziglang tooling (`zig fmt`, `zig build test`).

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live `zig fmt --check` when on PATH unless `ZIG_FMT_CONFIG_ONLY=1`). Build-test gate checks build.zig test step / CI / Makefile wiring.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/zig-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-zig` (Zig stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`zig-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `zig-hotpath-gate` fails if that wall exceeds `ZIG_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and zigtools/zls `src/` under default budget.

### Escape

Line marker `zig-rg-allow` with a short rationale. Prefer named boundaries from `templates/try_alloc.zig` / `templates/error_return.zig` over scattered allows.

## Selfcheck

`bash scripts/zig-kit-selfcheck.sh` proves rg/hotpath/fmt/build-test gates discriminate fixtures, single-walk encode, budget discrimination (`ZIG_RG_BUDGET_MS=1`), and template presence.
