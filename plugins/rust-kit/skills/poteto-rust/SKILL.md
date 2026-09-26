---
name: poteto-rust
description: Poteto-mode bar for Rust products. Use for /poteto-mode on Rust work, or when Dark asks for poteto bar on Rust. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Rust

Apply `/poteto-mode` non-negotiables, then this leaf for Rust crates / CLIs / services.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/rust-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/rust-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `RUST_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/rust-fmt-gate.sh <product-root>` exits 0.
4. `bash scripts/rust-clippy-gate.sh <product-root>` exits 0 (or `RUST_CLIPPY_CONFIG_ONLY=1` documented when clippy binary absent).
5. `bash scripts/rust-test-ci-gate.sh <product-root>` exits 0.
6. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious SAFETY / FFI / external constraints.
7. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
8. If unsafe / FFI / transmute touched: SAFETY docs, named boundary templates, `rust-rg-allow` on the smell line.
9. Stricter product gates (`cargo clippy -D warnings`, Miri, deny lints) override when present. Prove on the real artifact (`cargo test`).
10. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- `rustfmt` / Clippy wiring stay on
- Public crate API unchanged unless the goal is an API break
- `cargo test` wiring in CI/Makefile stays on
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent

## Ranked bar

1. Trust boundary (unsafe / FFI / net / parse) before micro-opts
2. Delete dead path before adding
3. Safe wrappers before more unsafe
4. Named domain errors before panic/unwrap sprawl
5. Measure (criterion / flamegraph) before further micro-opt

Load skill **rust** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Document mmap SAFETY invariants`, `Wire cargo clippy in CI`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Rust only)

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
| PSR Rust alignment | checklist: rustfmt, Clippy, cargo test wired, SAFETY on unsafe, FFI docs, no unchecked transmute, lockfile policy stated |
| CI green | `rust-rg-gate` + `rust-hotpath-gate` + `rust-fmt-gate` + `rust-clippy-gate` + `rust-test-ci-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Rust uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Rust passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
