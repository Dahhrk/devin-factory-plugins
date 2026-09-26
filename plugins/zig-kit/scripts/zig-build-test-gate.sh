#!/usr/bin/env bash
# Tier 1: require zig build test wiring (PSR Zig language-farm).
# Does not run the suite (host/toolchain dependent); proves build.zig test
# step and/or CI / Makefile encode `zig build test`.
# Escape: ZIG_BUILD_TEST_GATE_SKIP=1.
# Usage: bash scripts/zig-build-test-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${ZIG_BUILD_TEST_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS zig-build-test-gate (skipped via ZIG_BUILD_TEST_GATE_SKIP=1)"
  exit 0
fi

found=0

# Match: zig build test | zig build check test
PAT='zig[[:space:]]+build[[:space:]]+(check[[:space:]]+)?test'

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if rg -q -- "$PAT" "$f" 2>/dev/null; then found=1; fi
}

check_file Makefile
check_file makefile

# build.zig: addTest / step("test" / .step("test"
if [[ -f build.zig ]]; then
  if rg -q 'addTest|\.step\("test"|step\("test"' build.zig 2>/dev/null; then
    found=1
  fi
  if rg -q -- "$PAT" build.zig 2>/dev/null; then found=1; fi
fi

if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no zig build test wiring (build.zig addTest/test step or CI / Makefile; PSR language-farm requires zig build test)"
  exit 1
fi
echo "PASS zig-build-test-gate ($ROOT)"
