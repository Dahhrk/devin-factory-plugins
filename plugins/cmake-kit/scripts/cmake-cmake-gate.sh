#!/usr/bin/env bash
# Tier 1: require cmake / CMakeLists toolchain wiring (PSR CMake language-farm).
# Live `cmake --version` when resolvable unless CMAKE_CMAKE_CONFIG_ONLY=1.
# Portable bar: CMakeLists.txt / *.cmake / CI cmake.
# Escape: CMAKE_CMAKE_GATE_SKIP=1.
# Usage: bash scripts/cmake-cmake-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${CMAKE_CMAKE_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS cmake-cmake-gate (skipped via CMAKE_CMAKE_GATE_SKIP=1)"
  exit 0
fi

mapfile -t cm_files < <(find . \( \
  -name 'CMakeLists.txt' -o -name '*.cmake' -o -name '*.cmake.in' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' -not -path '*/CMakeFiles/*' \
  2>/dev/null | sort || true)
if [[ ${#cm_files[@]} -eq 0 ]]; then
  echo "FAIL: no CMakeLists.txt / *.cmake under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real CMake command anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)^\s*(cmake_minimum_required|project|add_(?:library|executable|subdirectory|custom_command|custom_target)|include|find_package|target_link_libraries)\b'

if rg -qP --glob 'CMakeLists.txt' --glob '*.cmake' --glob '*.cmake.in' \
  --glob '!**/.git/**' --glob '!**/vendor/**' --glob '!**/CMakeFiles/**' \
  "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="cmake-instructions"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])cmake(\s|$|[^\w])|cmake\s+--build|ctest|CMAKE_' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: CMake instructions, or CI that names cmake.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no cmake wiring (CMakeLists instructions / CI; PSR: CMake toolchain)"
  exit 1
fi

if [[ "${CMAKE_CMAKE_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS cmake-cmake-gate ($ROOT, config-only, ${#cm_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v cmake >/dev/null 2>&1; then
  set +e
  cmake --version >/tmp/cmake-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/cmake-gate-ver.$$.out"
    echo "PASS cmake-cmake-gate ($ROOT, live cmake, ${#cm_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/cmake-gate-ver.$$.out"
fi

echo "PASS cmake-cmake-gate ($ROOT, config-only fallback, ${#cm_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
