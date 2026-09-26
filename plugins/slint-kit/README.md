# slint-kit

Slint bar for the dark factory Cursor lane. Public research pilot: MIT-licensed portions of slint-ui/slint (`examples/`, docs) plus official slint-ui/slint-rust-template (MIT). Corroboration: Vadoola/Tomotroid (MIT, active Rust+Slint desktop; as_weak callback pattern). Framework runtime is triple-licensed (Royalty-free / GPL-3.0 / Commercial); this pack farms MIT examples/templates only.

| Surface | Path |
|---------|------|
| Skills | `skills/slint`, `skills/poteto-slint` |
| Rule | `rules/slint.mdc` (`**/*.{slint,rs,toml}`, not alwaysApply) |
| Tier 0 | `scripts/slint-rg-gate.sh` (debug() in .slint; clone_strong; unsafe { in .on_ hosts; **single-walk**; requires **rg** + PCRE `-P`) |
| Tier 0.5 | `scripts/slint-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `SLINT_RG_BUDGET_MS`) |
| Tier 1 | `scripts/slint-cargo-gate.sh` (Slint `Cargo.toml` / `build.rs` / CMake / CI wiring) |
| Selfcheck | `scripts/slint-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/slint-gates.yml` |
| Boundaries | `templates/no_debug_slint.slint`, `templates/as_weak_callback.rs`, `templates/safe_callback_host.rs` |

PSR Slint encode (Programming Standards Reference): no leftover `debug(` in `.slint`; no `clone_strong()` for callback capture (prefer `as_weak`); no `unsafe {` in Rust files that register `.on_` callbacks without allow. Primary authority: portable trust bar for Slint product trees. Toolchain: **slint** / **Cargo** (or CMake) wiring required at 0.1.0.

Compose with `/poteto-mode`. Tier 1 cargo checks wiring (config-only at 0.1.0).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/slint-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-slint` (Slint stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`slint-rg-gate` walks the tree **once** (union of line smells), classifies the hit set in parallel. `slint-hotpath-gate` fails if that wall exceeds `SLINT_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `slint-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_debug_slint.slint` / `templates/as_weak_callback.rs` / `templates/safe_callback_host.rs` over scattered allows.

## Selfcheck

`bash scripts/slint-kit-selfcheck.sh` proves rg/hotpath/cargo gates discriminate fixtures, single-walk encode, budget discrimination (`SLINT_RG_BUDGET_MS=1`), cargo wiring bar, and template presence.
