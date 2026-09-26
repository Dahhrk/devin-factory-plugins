#!/usr/bin/env bash
# Prove batchfile-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/bat-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/bat-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/bat-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env BAT_RG_BUDGET_MS=1 bash "$HERE/bat-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-batch env BAT_BATCH_CONFIG_ONLY=1 bash "$HERE/bat-batch-gate.sh" "$ROOT/testdata/good" &
probe batch-missing env BAT_BATCH_CONFIG_ONLY=1 bash "$HERE/bat-batch-gate.sh" "$ROOT/testdata/batch-missing" &
probe batch-weak env BAT_BATCH_CONFIG_ONLY=1 bash "$HERE/bat-batch-gate.sh" "$ROOT/testdata/batch-weak" &
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
check_fail tight-hot "hotpath budget fails when BAT_RG_BUDGET_MS=1"
check_pass good-batch "batch passes on good (config)"
check_fail batch-missing "batch fails without wiring"
check_fail batch-weak "batch fails without batch instructions / dep / CI"

require_grep "$HERE/bat-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/bat-hotpath-gate.sh" 'BAT_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/bat-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.bat" 'cd %WORKDIR%' "bad fixture encodes unquoted %VAR%"
require_grep "$ROOT/testdata/bad/smell.bat" 'EnableDelayedExpansion' "bad fixture encodes delayedExpansion"
require_grep "$ROOT/testdata/bad/smell.bat" 'call %USER_SCRIPT%' "bad fixture encodes call untrusted"
require_grep "$ROOT/testdata/bad/smell.bat" 'curl.*\|.*powershell|curl.*\| powershell' "bad fixture encodes curl|powershell"
require_grep "$ROOT/testdata/bad/smell.bat" 'set PASSWORD=' "bad fixture encodes secrets in set"
require_grep "$ROOT/testdata/good/ok.bat" 'cd /d "%WORKDIR%"' "good fixture encodes quoted var"
require_grep "$ROOT/testdata/good/ok.bat" 'call :greet' "good fixture encodes static call :label"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'cmd' "good CI encodes cmd"
require_grep "$ROOT/templates/quoted_var.bat" 'cd /d "%WORKDIR%"' "quoted_var template encodes quoted path"
require_grep "$ROOT/templates/no_delayed_expansion.bat" 'setlocal$' "no_delayed_expansion template encodes plain setlocal"
require_grep "$ROOT/templates/trusted_static_call.bat" 'call :work' "trusted_static_call template encodes :label"
require_grep "$ROOT/templates/no_curl_powershell.bat" 'install\.bat' "no_curl_powershell template encodes install.bat"
require_grep "$ROOT/templates/no_secrets_in_set.bat" 'AUTH_TOKEN' "no_secrets_in_set template encodes env check"

for f in quoted_var.bat no_delayed_expansion.bat trusted_static_call.bat no_curl_powershell.bat no_secrets_in_set.bat github-workflows/bat-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS batchfile-kit-selfcheck"
