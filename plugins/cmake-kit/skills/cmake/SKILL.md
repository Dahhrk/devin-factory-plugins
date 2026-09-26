---
name: cmake
description: PSR CMake encode for product CMakeLists and modules. Use when editing CMakeLists.txt / *.cmake or cmake CI wiring.
disable-model-invocation: false
---

# CMake

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference CMake checks into product gates.

## PSR CMake (encoded)

1. **Agreed toolchain** — CMakeLists.txt / *.cmake / CI `cmake`. Gate: `scripts/cmake-cmake-gate.sh`. Product CI: `templates/github-workflows/cmake-gates.yml`.
2. **file(DOWNLOAD) without hash** — no `file(DOWNLOAD ...)` missing `EXPECTED_HASH` / `EXPECTED_MD5` on the same physical line without allow. Prefer `EXPECTED_HASH SHA256=...`. Gate: `scripts/cmake-rg-gate.sh` (single-walk). Template: `templates/download_expected_hash.cmake`.
3. **unchecked execute_process** — no `execute_process(...)` missing `RESULT_VARIABLE` / `RESULTS_VARIABLE` / `COMMAND_ERROR_IS_FATAL` on the same physical line without allow. Gate: `scripts/cmake-rg-gate.sh`. Template: `templates/execute_process_checked.cmake`.
4. **GLOB for sources** — no `file(GLOB|GLOB_RECURSE)` collecting `*.{c,cc,cpp,cxx,cu,h,hh,hpp,hxx,m,mm}` without allow. Prefer explicit source lists (Kitware: "We do not recommend using GLOB to collect a list of source files"). Gate: `scripts/cmake-rg-gate.sh`. Template: `templates/explicit_sources.cmake`.
5. **CACHE FORCE abuse** — no `set(... CACHE ... FORCE)` without allow. Prefer `set` without FORCE or `option()`. Gate: `scripts/cmake-rg-gate.sh`. Template: `templates/cache_no_force.cmake`.
6. **include of untrusted path** — no `include(${...})` variable / untrusted path without allow. Prefer static `include(ModuleName)` or a vetted source-tree path. Gate: `scripts/cmake-rg-gate.sh`. Template: `templates/trusted_static_include.cmake`.
7. **Hot-path** — `scripts/cmake-hotpath-gate.sh` fails if rg-gate wall exceeds `CMAKE_RG_BUDGET_MS` (default 250ms).

## Rules

- `cmake-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-cmake**.
