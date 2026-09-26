#!/usr/bin/env bash
# Tier 1: require race testing wired in Makefile and/or CI (PSR: go test + race).
# Does not run the race suite (slow); proves the product encodes race in automation.
# Usage: bash scripts/go-race-ci-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
found=0

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -q -- '-race' "$f"; then found=1; fi
  else
    if grep -Eq -- '-race' "$f"; then found=1; fi
  fi
}

check_file Makefile
check_file makefile
if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no -race in Makefile or .github/workflows (PSR: race testing where supported)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS go-race-ci-gate ($ROOT)"
