#!/usr/bin/env bash
# Tier 0.5b: require -Wall and -Wextra wired (PSR: strong compiler diagnostics).
# Checks CMakeLists.txt / Makefile* / meson.build / compile_flags.txt / CI yml.
# Usage: bash scripts/cpp-warn-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

fail=0
has_wall=0
has_extra=0

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -q -- '-Wall' "$f"; then has_wall=1; fi
    if rg -q -- '-Wextra' "$f"; then has_extra=1; fi
  else
    if grep -q -- '-Wall' "$f"; then has_wall=1; fi
    if grep -q -- '-Wextra' "$f"; then has_extra=1; fi
  fi
  return 0
}

for f in CMakeLists.txt meson.build compile_flags.txt Makefile Makefile.am makefile; do
  check_file "$f"
done

if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$has_wall" -eq 0 ]]; then
  echo "FAIL: -Wall not found in CMake/Make/meson/compile_flags/CI (PSR: strong diagnostics)"
  fail=1
fi
if [[ "$has_extra" -eq 0 ]]; then
  echo "FAIL: -Wextra not found in CMake/Make/meson/compile_flags/CI (PSR: strong diagnostics)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS cpp-warn-gate ($ROOT, -Wall -Wextra)"
