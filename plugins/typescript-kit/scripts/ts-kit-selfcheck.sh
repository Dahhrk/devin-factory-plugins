#!/usr/bin/env bash
# Prove typescript-kit gates discriminate fixtures (pack maturity).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
fail=0

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

# good must PASS runtime
if ! bash "$HERE/ts-runtime-gate.sh" "$ROOT/testdata/good" >/tmp/ts-kit-selfcheck-good-runtime.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-runtime-gate PASS on testdata/good"
  cat /tmp/ts-kit-selfcheck-good-runtime.txt
  fail=1
else
  echo "ok: runtime passes on good"
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

# missing runtime proof must FAIL
if bash "$HERE/ts-runtime-gate.sh" "$ROOT/testdata/runtime-missing" >/tmp/ts-kit-selfcheck-runtime-missing.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-runtime-gate FAIL on testdata/runtime-missing"
  cat /tmp/ts-kit-selfcheck-runtime-missing.txt
  fail=1
else
  echo "ok: runtime fails when missing"
fi

# library .d.ts any: product mode FAIL, library skip PASS
if bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/library-dts" >/tmp/ts-kit-selfcheck-lib-product.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-rg-gate FAIL on library-dts in product mode"
  cat /tmp/ts-kit-selfcheck-lib-product.txt
  fail=1
else
  echo "ok: product mode flags .d.ts any"
fi

if ! TS_RG_SKIP_DTS=1 bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/library-dts" >/tmp/ts-kit-selfcheck-lib-skip.txt 2>&1; then
  echo "FAIL selfcheck: expected ts-rg-gate PASS on library-dts with TS_RG_SKIP_DTS=1"
  cat /tmp/ts-kit-selfcheck-lib-skip.txt
  fail=1
else
  echo "ok: library mode skips .d.ts any"
fi

# oxlint template must exist and name the factory-wide rules
OXLINT="$ROOT/templates/oxlintrc.json"
if [[ ! -f "$OXLINT" ]]; then
  echo "FAIL selfcheck: missing templates/oxlintrc.json"
  fail=1
else
  missing=0
  for key in no-explicit-any no-non-null-assertion switch-exhaustiveness-check ban-ts-comment; do
    if ! grep -q "$key" "$OXLINT"; then
      echo "FAIL selfcheck: oxlintrc missing $key"
      missing=1
    fi
  done
  if [[ "$missing" -eq 0 ]]; then
    echo "ok: oxlint template encodes any / non-null / exhaustive-switch / ban-ts-comment"
  else
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-kit-selfcheck"
