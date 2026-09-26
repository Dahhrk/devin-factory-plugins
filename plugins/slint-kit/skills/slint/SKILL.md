---
name: slint
description: Slint PSR bar. .slint debug() hygiene banned, clone_strong callback capture banned, unsafe blocks in .on_ callback hosts banned, slint/Cargo wiring. Use when reading or editing any .slint / Slint host Rust in a factory product.
paths: ["**/*.slint", "**/*.rs", "**/Cargo.toml", "**/build.rs", "**/.github/workflows/**"]
---

# Slint

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Slint checks into product gates.

## PSR Slint (encoded)

1. **.slint hygiene / debug()** — no leftover `debug(` in `.slint` without allow. Prefer remove before merge; use `SLINT_DEBUG_PERFORMANCE` env for frame probes. Gate: `scripts/slint-rg-gate.sh` (single-walk). Template: `templates/no_debug_slint.slint`.
2. **clone_strong callback capture** — no `clone_strong()` without allow when wiring Slint callbacks. Prefer `as_weak` / `upgrade` / `upgrade_in_event_loop`. Gate: `scripts/slint-rg-gate.sh`. Template: `templates/as_weak_callback.rs`.
3. **unsafe in .on_ callback hosts** — no `unsafe {` blocks in Rust files that register `.on_` callbacks without allow + SAFETY docs. Gate: `scripts/slint-rg-gate.sh` (scoped). Template: `templates/safe_callback_host.rs`.
4. **Hot-path** — `scripts/slint-hotpath-gate.sh` fails if rg-gate wall exceeds `SLINT_RG_BUDGET_MS` (default 250ms).
5. **slint / Cargo wiring** — `.slint` sources plus `Cargo.toml` / `build.rs` / CMake / CI mentioning `slint` or `slint-build`. Gate: `scripts/slint-cargo-gate.sh`. Product CI: `templates/github-workflows/slint-gates.yml`.

## Rules

- `slint-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-slint**.
