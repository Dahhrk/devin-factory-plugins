#!/usr/bin/env bash
# Prove c-kit gates discriminate fixtures (pack maturity).
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

expect_fail bad-rg "rg fails on bad" bash "$HERE/c-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/c-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/c-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when C_RG_BUDGET_MS=1" env C_RG_BUDGET_MS=1 bash "$HERE/c-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good (config)" env C_FMT_CONFIG_ONLY=1 bash "$HERE/c-fmt-gate.sh" "$ROOT/testdata/good" &
expect_fail fmt-missing "fmt fails without .clang-format" env C_FMT_CONFIG_ONLY=1 bash "$HERE/c-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
wait

expect_pass good-warn "warn passes with -Wall -Wextra" bash "$HERE/c-warn-gate.sh" "$ROOT/testdata/good"
expect_fail warn-missing "warn fails without -Wall -Wextra" bash "$HERE/c-warn-gate.sh" "$ROOT/testdata/warn-missing"
expect_pass good-san "san-ci passes with ASAN wiring" bash "$HERE/c-san-ci-gate.sh" "$ROOT/testdata/good"
expect_fail san-missing "san-ci fails without sanitizer wiring" bash "$HERE/c-san-ci-gate.sh" "$ROOT/testdata/san-missing"
expect_pass good-malloc "malloc passes with NULL checks" bash "$HERE/c-malloc-gate.sh" "$ROOT/testdata/good"
expect_fail malloc-bad "malloc fails without NULL check" bash "$HERE/c-malloc-gate.sh" "$ROOT/testdata/malloc-bad"

require_grep "$HERE/c-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/c-hotpath-gate.sh" 'C_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/c-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.c" 'strcpy' "bad fixture encodes strcpy"
require_grep "$ROOT/testdata/bad/smell.c" 'strcat' "bad fixture encodes strcat"
require_grep "$ROOT/testdata/bad/smell.c" 'sprintf' "bad fixture encodes sprintf"
require_grep "$ROOT/testdata/bad/smell.c" 'gets' "bad fixture encodes gets"
require_grep "$ROOT/testdata/good/ok.c" 'c-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/bounded_string.c" 'snprintf' "bounded_string template encodes snprintf"
require_grep "$ROOT/templates/malloc_check.c" 'NULL' "malloc_check template encodes NULL check"

for f in bounded_string.c malloc_check.c clang-format github-workflows/c-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS c-kit-selfcheck"
