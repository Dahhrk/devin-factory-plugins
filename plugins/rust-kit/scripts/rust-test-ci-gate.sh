#!/usr/bin/env bash
# Tier 1: require cargo test wired in Makefile and/or CI (PSR: cargo test).
# Does not run the suite (slow); proves the product encodes tests in automation.
# Accepts literal `cargo test` and GitHub Actions `${{ env.CARGO }} test` (cross).
# Usage: bash scripts/rust-test-ci-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
found=0

# Match: cargo test | ${{ env.CARGO }} test | $CARGO test
PAT='cargo[[:space:]]+test|\$\{\{[[:space:]]*env\.CARGO[[:space:]]*\}\}[[:space:]]+test|\$\{?CARGO\}?[[:space:]]+test'

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -q -- "$PAT" "$f"; then found=1; fi
  else
    if grep -Eq -- 'cargo[[:space:]]+test|env\.CARGO.*test|\$CARGO[[:space:]]+test' "$f"; then found=1; fi
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
  echo "FAIL: no cargo test (or \${{ env.CARGO }} test) in Makefile or .github/workflows (PSR: cargo test)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS rust-test-ci-gate ($ROOT)"
