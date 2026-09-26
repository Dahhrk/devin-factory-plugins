# cmake-kit

CMake bar for the dark factory Cursor lane. Public research pilot: Kitware/CMake (BSD-3-Clause) command reference (`file(DOWNLOAD)` / `EXPECTED_HASH`, `execute_process`, `file(GLOB)`, `set(...CACHE...FORCE)`, `include`).

| Surface | Path |
|---------|------|
| Skills | `skills/cmake`, `skills/poteto-cmake` |
| Rule | `rules/cmake.mdc` (`**/CMakeLists.txt`, `**/*.cmake`, `**/*.cmake.in`, not alwaysApply) |
| Tier 0 | `scripts/cmake-rg-gate.sh` (file(DOWNLOAD) without hash; unchecked execute_process; GLOB for sources; CACHE FORCE abuse; include of untrusted path; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/cmake-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `CMAKE_RG_BUDGET_MS`) |
| Tier 1 | `scripts/cmake-cmake-gate.sh` (CMakeLists.txt / *.cmake / CI cmake wiring / live `cmake --version` when resolvable) |
| Selfcheck | `scripts/cmake-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/cmake-gates.yml` |
| Boundaries | `templates/download_expected_hash.cmake`, `templates/execute_process_checked.cmake`, `templates/explicit_sources.cmake`, `templates/cache_no_force.cmake`, `templates/trusted_static_include.cmake` |

PSR CMake encode (Programming Standards Reference): require `EXPECTED_HASH` / `EXPECTED_MD5` on `file(DOWNLOAD)`; check `execute_process` with `RESULT_VARIABLE` / `RESULTS_VARIABLE` / `COMMAND_ERROR_IS_FATAL`; never `file(GLOB)` / `GLOB_RECURSE` for source lists (list sources explicitly); avoid `set(... CACHE ... FORCE)` overwrite abuse; never `include(${...})` of untrusted / variable paths (prefer static module names or vetted absolute paths under the source tree). Primary authority: Kitware/CMake Help command docs — BSD-3-Clause.

Compose with `/poteto-mode`. Tier 1 checks cmake wiring (live `cmake --version` when resolvable unless `CMAKE_CMAKE_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/cmake-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-cmake` (CMake / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`cmake-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `cmake-hotpath-gate` fails if that wall exceeds `CMAKE_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `cmake-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer `EXPECTED_HASH` on the same physical line as `file(DOWNLOAD)` for the portable rg bar. Prefer checked `execute_process`. Prefer explicit source lists. Prefer CACHE without FORCE. Prefer static `include(ModuleName)`.

## Selfcheck

`bash scripts/cmake-kit-selfcheck.sh` proves rg/hotpath/cmake gates discriminate fixtures, single-walk encode, budget discrimination (`CMAKE_RG_BUDGET_MS=1`), cmake wiring bar, and template presence.
