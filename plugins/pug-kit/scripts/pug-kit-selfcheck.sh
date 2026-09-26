#!/usr/bin/env bash
# Prove pug-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/pug-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/pug-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/pug-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env PUG_RG_BUDGET_MS=1 bash "$HERE/pug-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-pug env PUG_PUG_CONFIG_ONLY=1 bash "$HERE/pug-pug-gate.sh" "$ROOT/testdata/good" &
probe pug-missing env PUG_PUG_CONFIG_ONLY=1 bash "$HERE/pug-pug-gate.sh" "$ROOT/testdata/pug-missing" &
probe pug-weak env PUG_PUG_CONFIG_ONLY=1 bash "$HERE/pug-pug-gate.sh" "$ROOT/testdata/pug-weak" &
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
check_fail tight-hot "hotpath budget fails when PUG_RG_BUDGET_MS=1"
check_pass good-pug "pug passes on good (config)"
check_fail pug-missing "pug fails without wiring"
check_fail pug-weak "pug fails without package.json pug / CI pug"

require_grep "$HERE/pug-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/pug-hotpath-gate.sh" 'PUG_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/pug-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.pug" '!=' "bad fixture encodes unescaped !="
require_grep "$ROOT/testdata/bad/smells.pug" 'include #\{' "bad fixture encodes interpolated include"
require_grep "$ROOT/testdata/bad/smells.pug" '\+#\{' "bad fixture encodes dynamic mixin"
require_grep "$ROOT/testdata/good/ok.pug" 'pug-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/ok.pug" 'p=' "good fixture encodes buffered ="
require_grep "$ROOT/testdata/good/package.json" '"pug"' "good package.json encodes pug dep"
require_grep "$ROOT/templates/buffered_escaped_output.pug" '^p=' "buffered_escaped_output template encodes buffered ="
require_grep "$ROOT/templates/trusted_static_include.pug" 'include ' "trusted_static_include template encodes static include"
require_grep "$ROOT/templates/static_mixin_call.pug" '^\+card' "static_mixin_call template encodes static mixin"

for f in buffered_escaped_output.pug trusted_static_include.pug static_mixin_call.pug github-workflows/pug-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS pug-kit-selfcheck"
