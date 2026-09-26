---
name: fortran
description: Fortran PSR bar. fortitude lint, implicit none, no GOTO, checked I/O (iostat). fprettify format. Use when reading or editing any .f90/.F90/.fypp in a factory product.
paths: ["**/*.f90", "**/*.F90", "**/*.f95", "**/*.F95", "**/*.f03", "**/*.F03", "**/*.f08", "**/*.F08", "**/*.f", "**/*.F", "**/*.fypp", "**/.fortitude.toml", "**/fortitude.toml", "**/pyproject.toml", "**/.github/workflows/**"]
---

# Fortran

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Fortran checks into product gates.

## PSR Fortran (encoded)

1. **Agreed linter** — `fortitude` (`.fortitude.toml` / `fortitude.toml` / `[tool.fortitude]` / CI `fortitude check` / live). Gate: `scripts/fortran-fortitude-gate.sh`. Product CI: `templates/github-workflows/fortran-gates.yml`. Config must keep **C001** / **implicit-typing** enabled (not ignored).
2. **implicit none** — every `program` / `module` has `implicit none`; no old-style `implicit <type>` without allow. Prefer fortitude C001. Gate: `scripts/fortran-rg-gate.sh` (single-walk). Template: `templates/implicit_none.f90`.
3. **GOTO** — no `GOTO` / `GO TO` without allow. Prefer `select case`, structured loops, early `return`. Gate: `scripts/fortran-rg-gate.sh`. Template: `templates/no_goto.f90`.
4. **Unchecked I/O** — `open` / `read` / `write` / `close` carry `iostat=` (prefer `iomsg=` too) without allow. Gate: `scripts/fortran-rg-gate.sh`. Template: `templates/checked_io.f90`.
5. **Hot-path** — `scripts/fortran-hotpath-gate.sh` fails if rg-gate wall exceeds `FORTRAN_RG_BUDGET_MS` (default 250ms).
6. **Formatter** — **fprettify** recommended for whitespace/indent; not a hard EXIT at 0.1.0.

## Rules

- `fortran-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-fortran**.
