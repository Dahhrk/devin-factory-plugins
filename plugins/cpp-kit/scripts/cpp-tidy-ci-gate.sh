#!/usr/bin/env bash
# Tier 1: require clang-tidy wiring where practical (PSR C++).
# Does not run clang-tidy (slow/host-dependent); proves .clang-tidy exists
# or clang-tidy is encoded in CMake options or CI.
# Usage: bash scripts/cpp-tidy-ci-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
found=0

if [[ -f .clang-tidy ]] || [[ -f clang-tidy ]]; then
  found=1
fi

PAT='clang-tidy|\.clang-tidy'

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -qi -- "$PAT" "$f"; then found=1; fi
  else
    if grep -Eiq -- 'clang-tidy' "$f"; then found=1; fi
  fi
  return 0
}

for f in CMakeLists.txt meson.build Makefile Makefile.am makefile; do
  check_file "$f"
done

if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no clang-tidy wiring (.clang-tidy or clang-tidy in CMake/CI) (PSR: clang-tidy where practical)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS cpp-tidy-ci-gate ($ROOT)"
