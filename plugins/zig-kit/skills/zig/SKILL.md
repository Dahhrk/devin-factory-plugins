---
name: zig
description: Zig PSR bar. zig fmt, zig build test wiring, no @panic/@trap in libs, no catch unreachable unchecked alloc, no TODO/FIXME. Use when reading or editing any .zig in a factory product.
paths: ["**/*.zig", "**/build.zig", "**/build.zig.zon", "**/.github/workflows/**"]
---

# Zig

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Zig checks into product gates.

## PSR Zig (encoded)

1. **Agreed formatter** — `zig fmt` (CI `zig fmt --check` / live zig). Gate: `scripts/zig-fmt-gate.sh`. Product CI: `templates/github-workflows/zig-gates.yml`.
2. **zig build test** — `build.zig` test step and/or CI `zig build test`. Gate: `scripts/zig-build-test-gate.sh` (wiring; not live suite run).
3. **@panic / @trap** — no `@panic` / `@trap` in library paths without allow. Prefer error unions / `return error.`. Gate: `scripts/zig-rg-gate.sh` (single-walk). Template: `templates/error_return.zig`.
4. **Unchecked alloc** — no `catch unreachable` without allow (covers ignored alloc and other unchecked error unions). Prefer `try` / `errdefer`. Gate: `scripts/zig-rg-gate.sh`. Template: `templates/try_alloc.zig`.
5. **TODO / FIXME** — no bare `TODO` / `FIXME` without allow. Finish the work or track outside product paths. Gate: `scripts/zig-rg-gate.sh`.
6. **Hot-path** — `scripts/zig-hotpath-gate.sh` fails if rg-gate wall exceeds `ZIG_RG_BUDGET_MS` (default 250ms).

## Rules

- `zig-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-zig**.
