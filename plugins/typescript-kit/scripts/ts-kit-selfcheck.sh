#!/usr/bin/env bash
# Prove typescript-kit gates discriminate bad vs good fixtures (pack maturity).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
fail=0

run() {
  local label="$1"
  shift
  if "$@"; then
    echo "ok: $label"
  else
    echo "FAIL selfcheck: $label"
    fail=1
  fi
}

# bad must FAIL rg
if bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/bad" >/tmp/ts-kit-selfcheck-bad.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-rg-gate FAIL on testdata/bad"
  cat /tmp/ts-kit-selfcheck-bad.txt
  fail=1
else
  echo "ok: rg fails on bad"
fi

# good must PASS rg
if ! bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/good" >/tmp/ts-kit-selfcheck-good-rg.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-rg-gate PASS on testdata/good"
  cat /tmp/ts-kit-selfcheck-good-rg.txt
  fail=1
else
  echo "ok: rg passes on good"
fi

# good must PASS strict
if ! bash "$HERE/ts-strict-gate.sh" "$ROOT/testdata/good" >/tmp/ts-kit-selfcheck-good-strict.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-strict-gate PASS on testdata/good"
  cat /tmp/ts-kit-selfcheck-good-strict.txt
  fail=1
else
  echo "ok: strict passes on good"
fi

# extends chain must PASS strict (strict only on base)
if ! bash "$HERE/ts-strict-gate.sh" "$ROOT/testdata/extends-ok" >/tmp/ts-kit-selfcheck-extends.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-strict-gate PASS on testdata/extends-ok"
  cat /tmp/ts-kit-selfcheck-extends.txt
  fail=1
else
  echo "ok: strict walks extends"
fi

# missing strict / typecheck must FAIL
if bash "$HERE/ts-strict-gate.sh" "$ROOT/testdata/strict-missing" >/tmp/ts-kit-selfcheck-strict-missing.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-strict-gate FAIL on testdata/strict-missing"
  cat /tmp/ts-kit-selfcheck-strict-missing.txt
  fail=1
else
  echo "ok: strict fails when missing"
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-kit-selfcheck"
