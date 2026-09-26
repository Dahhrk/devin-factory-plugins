#!/usr/bin/env bash
# Prove mako-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/mako-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/mako-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/mako-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env MAKO_RG_BUDGET_MS=1 bash "$HERE/mako-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-mako env MAKO_MAKO_CONFIG_ONLY=1 bash "$HERE/mako-mako-gate.sh" "$ROOT/testdata/good" &
probe mako-missing env MAKO_MAKO_CONFIG_ONLY=1 bash "$HERE/mako-mako-gate.sh" "$ROOT/testdata/mako-missing" &
probe mako-weak env MAKO_MAKO_CONFIG_ONLY=1 bash "$HERE/mako-mako-gate.sh" "$ROOT/testdata/mako-weak" &
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
check_fail tight-hot "hotpath budget fails when MAKO_RG_BUDGET_MS=1"
check_pass good-mako "mako passes on good (config)"
check_fail mako-missing "mako fails without wiring"
check_fail mako-weak "mako fails without mako import / dep / CI"

require_grep "$HERE/mako-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/mako-hotpath-gate.sh" 'MAKO_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/mako-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.py" 'disable_unicode' "bad fixture encodes disable_unicode"
require_grep "$ROOT/testdata/bad/smells.py" 'input_encoding' "bad fixture encodes input_encoding"
require_grep "$ROOT/testdata/bad/smells.py" 'module_directory' "bad fixture encodes module_directory"
require_grep "$ROOT/testdata/bad/smells.py" 'default_filters' "bad fixture encodes empty default_filters"
require_grep "$ROOT/testdata/bad/smells.mako" 'include' "bad fixture encodes untrusted include"
require_grep "$ROOT/testdata/bad/smells.mako" '\| n|\|n' "bad fixture encodes |n raw"
require_grep "$ROOT/testdata/good/ok.py" 'mako-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/ok.py" 'from mako' "good fixture encodes mako import"
require_grep "$ROOT/testdata/good/requirements.txt" 'mako' "good requirements encodes mako"
require_grep "$ROOT/templates/page_html_filter.mako" 'expression_filter' "page_html_filter template encodes expression_filter"
require_grep "$ROOT/templates/trusted_static_include.mako" 'include' "trusted_static_include template encodes include"
require_grep "$ROOT/templates/filtered_expression.mako" '\|h' "filtered_expression template encodes |h"
require_grep "$ROOT/templates/lookup_no_module_dir.py" 'TemplateLookup' "lookup_no_module_dir template encodes TemplateLookup"

for f in page_html_filter.mako trusted_static_include.mako filtered_expression.mako lookup_no_module_dir.py github-workflows/mako-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS mako-kit-selfcheck"
