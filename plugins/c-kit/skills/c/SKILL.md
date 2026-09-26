---
name: c
description: C PSR bar. clang-format, -Wall -Wextra, sanitizers where practical, no unsafe string APIs, malloc NULL checks. Use when reading or editing any .c / .h / CMakeLists.txt in a factory product.
paths: ["**/*.c", "**/*.h", "**/CMakeLists.txt", "**/Makefile", "**/Makefile.am", "**/meson.build", "**/.clang-format", "**/.github/workflows/**"]
---

# C

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference C checks into product gates.

## PSR C (encoded)

1. **clang-format** — all C sources formatted. Gate: `scripts/c-fmt-gate.sh`. Starter: `templates/clang-format` (copy to `.clang-format`).
2. **Strong diagnostics** — `-Wall` and `-Wextra` in CMake/Make/meson/CI. Gate: `scripts/c-warn-gate.sh`.
3. **Sanitizers where practical** — ASAN/UBSAN/TSAN or `-fsanitize=` wired. Gate: `scripts/c-san-ci-gate.sh` (wiring); run sanitizer builds in product CI when the host supports them.
4. **Buffer / unsafe string smells** — no `strcpy` / `strcat` / `sprintf` / `gets`. Gate: `scripts/c-rg-gate.sh` (single-walk). Template: `templates/bounded_string.c`.
5. **malloc check** — every `malloc` / `calloc` / `realloc` NULL-checked nearby. Gate: `scripts/c-malloc-gate.sh`. Template: `templates/malloc_check.c`.
6. **Hot-path** — `scripts/c-hotpath-gate.sh` fails if rg-gate wall exceeds `C_RG_BUDGET_MS` (default 250ms).
7. **Ownership / UB** — prefer clear ownership, bounds-checked copies, and sanitizer-backed CI over silent undefined behaviour.

## Rules

- `c-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-c**.
