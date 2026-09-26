#!/usr/bin/env bash
# Tier 1: require sanitizer wiring where practical (PSR: sanitizers where supported).
# Does not run sanitizers (slow/host-dependent); proves ASAN/UBSAN/TSAN or
# -fsanitize= is encoded in CMake options or CI.
# Usage: bash scripts/c-san-ci-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
found=0

# Match: ASAN / UBSAN / TSAN options, AddressSanitizer, -fsanitize=
PAT='ASAN|UBSAN|TSAN|AddressSanitizer|UndefinedBehaviorSanitizer|ThreadSanitizer|-fsanitize='

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -qi -- "$PAT" "$f"; then found=1; fi
  else
    if grep -Eiq -- 'ASAN|UBSAN|TSAN|AddressSanitizer|fsanitize' "$f"; then found=1; fi
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
  echo "FAIL: no sanitizer wiring (ASAN/UBSAN/TSAN or -fsanitize=) in CMake/Make/CI (PSR: sanitizers where practical)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS c-san-ci-gate ($ROOT)"
