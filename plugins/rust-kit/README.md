# rust-kit

Rust bar for the dark factory Cursor lane. Public research pilot: BurntSushi/ripgrep (MIT/Unlicense).

| Surface | Path |
|---------|------|
| Skills | `skills/rust`, `skills/poteto-rust` |
| Rule | `rules/rust.mdc` (`**/*.rs`, not alwaysApply) |
| Tier 0 | `scripts/rust-rg-gate.sh` (unsafe / transmute / extern "C" / todo!|unimplemented! / #[no_mangle]; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/rust-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `RUST_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/rust-fmt-gate.sh` + `scripts/rust-clippy-gate.sh` |
| Tier 1 | `scripts/rust-test-ci-gate.sh` (Makefile or CI must wire `cargo test`) |
| Selfcheck | `scripts/rust-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/rust-gates.yml` + `templates/clippy/clippy.toml` + `templates/rustfmt.toml` |
| Boundaries | `templates/unsafe_boundary.rs`, `templates/ffi_extern.rs` |

PSR Rust encode (Programming Standards Reference): rustfmt, Clippy, cargo test; document unsafe invariants and FFI; avoid unchecked assumptions at external boundaries; choose application versus library lockfile policy deliberately. Primary authority: Rust Reference, edition guide, API guidance.

Compose with `/poteto-mode`. Tier 0.5 Clippy wiring is config/CI presence (live when clippy installed); rustfmt is live when tools exist else `rustfmt.toml`.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/rust-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-rust` (Rust stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`rust-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `rust-hotpath-gate` fails if that wall exceeds `RUST_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and ripgrep under default budget.

### Escape

Line marker `rust-rg-allow` with a short rationale. Prefer named boundaries from `templates/unsafe_boundary.rs` / `templates/ffi_extern.rs` over scattered allows.

## Selfcheck

`bash scripts/rust-kit-selfcheck.sh` proves rg/hotpath/fmt/clippy/test-ci gates discriminate fixtures, single-walk encode, budget discrimination (`RUST_RG_BUDGET_MS=1`), and template presence.
