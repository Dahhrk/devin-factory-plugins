#!/usr/bin/env bash
# Prove css-kit gates discriminate fixtures (pack maturity).
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

require_grep() {
  local file="$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]] || ! grep -q -E -e "$pat" -- "$file"; then
    echo "FAIL selfcheck: $label"; fail=1
  else
    echo "ok: $label"
  fi
}

probe bad-rg bash "$HERE/css-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/css-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/css-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env CSS_RG_BUDGET_MS=1 bash "$HERE/css-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-stylelint env CSS_STYLELINT_CONFIG_ONLY=1 bash "$HERE/css-stylelint-gate.sh" "$ROOT/testdata/good" &
probe stylelint-missing env CSS_STYLELINT_CONFIG_ONLY=1 bash "$HERE/css-stylelint-gate.sh" "$ROOT/testdata/stylelint-missing" &
probe stylelint-weak env CSS_STYLELINT_CONFIG_ONLY=1 bash "$HERE/css-stylelint-gate.sh" "$ROOT/testdata/stylelint-weak" &
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
check_fail tight-hot "hotpath budget fails when CSS_RG_BUDGET_MS=1"
check_pass good-stylelint "stylelint passes on good (config)"
check_fail stylelint-missing "stylelint fails without wiring"
check_fail stylelint-weak "stylelint fails without declaration-no-important / selector-max-universal"

require_grep "$HERE/css-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/css-hotpath-gate.sh" 'CSS_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/css-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.css" '!important' "bad fixture encodes !important"
require_grep "$ROOT/testdata/bad/smell.css" '\*' "bad fixture encodes universal selector"
require_grep "$ROOT/testdata/bad/smell.css" 'expression\(' "bad fixture encodes expression()"
require_grep "$ROOT/testdata/bad/smell.css" 'behavior:' "bad fixture encodes behavior:"
require_grep "$ROOT/testdata/good/ok.css" 'css-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/.stylelintrc.json" 'declaration-no-important' "good .stylelintrc.json encodes declaration-no-important"
require_grep "$ROOT/testdata/good/.stylelintrc.json" 'selector-max-universal' "good .stylelintrc.json encodes selector-max-universal"
require_grep "$ROOT/templates/specificity_over_important.css" 'color:' "specificity_over_important template encodes declaration"
require_grep "$ROOT/templates/scoped_reset.css" '\.app' "scoped_reset template encodes scoped selector"

for f in specificity_over_important.css scoped_reset.css .stylelintrc.json github-workflows/css-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS css-kit-selfcheck"
