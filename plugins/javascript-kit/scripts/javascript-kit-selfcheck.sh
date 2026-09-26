#!/usr/bin/env bash
# Prove javascript-kit gates discriminate fixtures (pack maturity).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
fail=0

probe() {
  local id="$1"; shift
  if "$@" >"$WORKDIR/$id.out" 2>&1; then echo 0 >"$WORKDIR/$id.rc"; else echo 1 >"$WORKDIR/$id.rc"; fi
}

expect_fail() {
  local id="$1" label="$2"; shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}

expect_pass() {
  local id="$1" label="$2"; shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}

require_grep() {
  local file="$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]] || ! grep -q -E -e "$pat" -- "$file"; then
    echo "FAIL selfcheck: $label"; fail=1
  else
    echo "ok: $label"
  fi
}

# Parallel probes (fail aggregation after wait; subshell fail= is discarded).
probe bad-rg bash "$HERE/js-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/js-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/js-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env JS_RG_BUDGET_MS=1 bash "$HERE/js-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env JS_FMT_CONFIG_ONLY=1 bash "$HERE/js-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env JS_FMT_CONFIG_ONLY=1 bash "$HERE/js-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
wait

check_fail() {
  local id="$1" label="$2"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}
check_pass() {
  local id="$1" label="$2"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}

check_fail bad-rg "rg fails on bad"
check_pass good-rg "rg passes on good"
check_pass good-hot "hotpath budget passes on good"
check_fail tight-hot "hotpath budget fails when JS_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without prettier wiring"

expect_pass good-eslint "eslint-flat passes with eslint.config.mjs" bash "$HERE/js-eslint-flat-gate.sh" "$ROOT/testdata/good"
expect_fail eslint-missing "eslint-flat fails without flat config" bash "$HERE/js-eslint-flat-gate.sh" "$ROOT/testdata/eslint-missing"
expect_fail eslint-legacy "eslint-flat fails on legacy .eslintrc only" bash "$HERE/js-eslint-flat-gate.sh" "$ROOT/testdata/eslint-legacy"

require_grep "$HERE/js-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/js-hotpath-gate.sh" 'JS_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/js-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.js" 'eval\(' "bad fixture encodes eval"
require_grep "$ROOT/testdata/bad/smell.js" '__proto__' "bad fixture encodes prototype pollution"
require_grep "$ROOT/testdata/bad/smell.js" 'readFileSync|statSync' "bad fixture encodes sync fs"
require_grep "$ROOT/testdata/good/src/ok.js" 'js-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/async_fs_read.js" 'promises|readFile' "async_fs_read template encodes async fs"
require_grep "$ROOT/templates/safe_object_merge.js" 'Object\.create\(null\)|__proto__' "safe_object_merge template encodes null-prototype merge"

for f in async_fs_read.js safe_object_merge.js eslint.config.mjs prettierrc.json github-workflows/js-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS javascript-kit-selfcheck"
