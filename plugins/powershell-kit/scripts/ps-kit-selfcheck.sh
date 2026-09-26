#!/usr/bin/env bash
# Prove powershell-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/ps-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/ps-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/ps-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env PS_RG_BUDGET_MS=1 bash "$HERE/ps-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-pssa env PS_PSSA_CONFIG_ONLY=1 bash "$HERE/ps-pssa-gate.sh" "$ROOT/testdata/good" &
probe pssa-missing env PS_PSSA_CONFIG_ONLY=1 bash "$HERE/ps-pssa-gate.sh" "$ROOT/testdata/pssa-missing" &
probe pssa-weak env PS_PSSA_CONFIG_ONLY=1 bash "$HERE/ps-pssa-gate.sh" "$ROOT/testdata/pssa-weak" &
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
check_fail tight-hot "hotpath budget fails when PS_RG_BUDGET_MS=1"
check_pass good-pssa "pssa passes on good (config)"
check_fail pssa-missing "pssa fails without wiring"
check_fail pssa-weak "pssa fails without PSAvoidUsingInvokeExpression / PSAvoidUsingWriteHost"

require_grep "$HERE/ps-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/ps-hotpath-gate.sh" 'PS_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/ps-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.ps1" 'Invoke-Expression' "bad fixture encodes Invoke-Expression"
require_grep "$ROOT/testdata/bad/smell.ps1" 'Test-Path \$' "bad fixture encodes unquoted path"
require_grep "$ROOT/testdata/bad/smell.psm1" 'Write-Host' "bad fixture encodes Write-Host in module"
require_grep "$ROOT/testdata/good/ok.ps1" 'ps-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/PSScriptAnalyzerSettings.psd1" 'PSAvoidUsingInvokeExpression' "good settings encode PSAvoidUsingInvokeExpression"
require_grep "$ROOT/testdata/good/PSScriptAnalyzerSettings.psd1" 'PSAvoidUsingWriteHost' "good settings encode PSAvoidUsingWriteHost"
require_grep "$ROOT/templates/no_iex.ps1" '& \$ScriptPath' "no_iex template encodes call operator"
require_grep "$ROOT/templates/write_output_not_host.psm1" 'Write-Output' "write_output_not_host template encodes Write-Output"
require_grep "$ROOT/templates/quoted_path.ps1" 'LiteralPath "\$PublishPath"' "quoted_path template encodes quoted path"

for f in no_iex.ps1 write_output_not_host.psm1 quoted_path.ps1 PSScriptAnalyzerSettings.psd1 github-workflows/ps-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ps-kit-selfcheck"
