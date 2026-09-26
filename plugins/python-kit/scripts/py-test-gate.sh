#!/usr/bin/env bash
# Tier 1: require tests present (PSR: test exceptions, I/O and runtime validation).
# Usage: bash scripts/py-test-gate.sh [root]
# Escape: PY_TEST_GATE_SKIP=1 for pure stubs.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${PY_TEST_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS py-test-gate (skipped via PY_TEST_GATE_SKIP=1)"
  exit 0
fi

found=0
[[ -d tests ]] && found=1
[[ -d test ]] && found=1
if compgen -G "test_*.py" >/dev/null || compgen -G "*_test.py" >/dev/null; then found=1; fi
if [[ -f pyproject.toml ]] && rg -q 'pytest|\[tool\.pytest' pyproject.toml 2>/dev/null; then
  # pytest wired counts only if a tests dir or test_ file also exists
  :
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no tests/ (or test_*.py) present (PSR: test exceptions, I/O, runtime validation)"
  exit 1
fi
echo "PASS py-test-gate ($ROOT)"
