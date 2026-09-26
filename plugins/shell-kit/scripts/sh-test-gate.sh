#!/usr/bin/env bash
# Tier 1: require shell tests present (PSR: test filenames / signals / empty).
# Looks for tests/ with *.sh, or test_*.sh / *_test.sh at root.
# Does not run the suite (fast presence bar); product CI runs bats/shunit/etc.
# Usage: bash scripts/sh-test-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

found=0
if [[ -d tests ]]; then
  if find tests \( -name '*.sh' -o -name '*.bats' -o -name 'test_*' \) 2>/dev/null | grep -q .; then
    found=1
  fi
fi
if compgen -G 'test_*.sh' >/dev/null || compgen -G '*_test.sh' >/dev/null; then
  found=1
fi
if [[ -d test ]] && find test \( -name '*.sh' -o -name '*.bats' \) 2>/dev/null | grep -q .; then
  found=1
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no shell tests (tests/*.sh|*.bats, test_*.sh, *_test.sh); cover filenames/signals/empty (see templates/test_edge.sh)"
  exit 1
fi
echo "PASS sh-test-gate ($ROOT)"
