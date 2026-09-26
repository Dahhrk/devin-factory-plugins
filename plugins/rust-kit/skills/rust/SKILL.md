---
name: rust
description: Rust PSR bar. rustfmt, Clippy, cargo test, document unsafe/FFI, no unchecked external boundaries, deliberate lockfile policy. Use when reading or editing any .rs / Cargo.toml in a factory product.
paths: ["**/*.rs", "**/Cargo.toml", "**/Cargo.lock", "**/rustfmt.toml", "**/clippy.toml", "**/.github/workflows/**"]
---

# Rust

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Rust checks into product gates.

## PSR Rust (encoded)

1. **rustfmt** — all Rust sources formatted. Gate: `scripts/rust-fmt-gate.sh`. Starter: `templates/rustfmt.toml`.
2. **Clippy** — lint with Clippy in CI / `[lints.clippy]` / clippy.toml. Gate: `scripts/rust-clippy-gate.sh`. Starter: `templates/clippy/clippy.toml`.
3. **cargo test** — unit/integration tests wired in Makefile or CI. Gate: `scripts/rust-test-ci-gate.sh` (wiring); run `cargo test` in product CI.
4. **Document unsafe invariants** — every `unsafe` has SAFETY rationale; prefer safe API. Gate: `scripts/rust-rg-gate.sh` (single-walk). Template: `templates/unsafe_boundary.rs`.
5. **Document FFI** — `extern "C"` / `#[no_mangle]` with ABI/ownership docs. Gate: `scripts/rust-rg-gate.sh`. Template: `templates/ffi_extern.rs`.
6. **Avoid unchecked external boundaries** — no transmute; no todo!/unimplemented! in prod paths. Gate: `scripts/rust-rg-gate.sh`.
7. **Hot-path** — `scripts/rust-hotpath-gate.sh` fails if rg-gate wall exceeds `RUST_RG_BUDGET_MS` (default 250ms).
8. **Lockfile policy** — commit `Cargo.lock` for binaries/apps; usually omit for publishable libraries. Record the choice in README or CONTRIBUTING.

## Rules

- `rust-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-rust**.
