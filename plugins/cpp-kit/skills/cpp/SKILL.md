---
name: cpp
description: C++ PSR bar. clang-format, -Wall -Wextra, clang-tidy where practical, no raw new/delete, no C-style casts, no sprintf/vsprintf. Use when reading or editing any .cpp / .cc / .cxx / .hpp / .hh / .h / CMakeLists.txt in a factory product.
paths: ["**/*.cpp", "**/*.cc", "**/*.cxx", "**/*.hpp", "**/*.hh", "**/*.h", "**/CMakeLists.txt", "**/Makefile", "**/Makefile.am", "**/meson.build", "**/.clang-format", "**/.clang-tidy", "**/.github/workflows/**"]
---

# C++

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference C++ checks into product gates.

## PSR C++ (encoded)

1. **clang-format** — all C++ sources formatted. Gate: `scripts/cpp-fmt-gate.sh`. Starter: `templates/clang-format` (copy to `.clang-format`).
2. **Strong diagnostics** — `-Wall` and `-Wextra` in CMake/Make/meson/CI. Gate: `scripts/cpp-warn-gate.sh`.
3. **clang-tidy where practical** — `.clang-tidy` or `clang-tidy` wired in CMake/CI. Gate: `scripts/cpp-tidy-ci-gate.sh` (wiring); run clang-tidy in product CI when the host supports it.
4. **Raw new/delete** — no `new Type(...)` / `new T[]` / `delete` / `delete[]` without allow. Prefer `std::unique_ptr` / `std::make_unique`. Gate: `scripts/cpp-rg-gate.sh` (single-walk). Template: `templates/unique_ptr_new.cpp`.
5. **C-style casts** — no `(T)x` / `(T*)p` for primitive/pointer types; prefer `static_cast` / `reinterpret_cast` / `const_cast`. Gate: `scripts/cpp-rg-gate.sh`. Template: `templates/static_cast.cpp`.
6. **sprintf family** — no `sprintf` / `vsprintf`. Prefer `{fmt}` / `std::format` / `snprintf`. Gate: `scripts/cpp-rg-gate.sh`.
7. **Hot-path** — `scripts/cpp-hotpath-gate.sh` fails if rg-gate wall exceeds `CPP_RG_BUDGET_MS` (default 250ms).

## Rules

- `cpp-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-cpp**.
