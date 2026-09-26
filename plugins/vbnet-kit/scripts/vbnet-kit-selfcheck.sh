#!/usr/bin/env bash
# Prove vbnet-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/vbnet-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/vbnet-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/vbnet-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env VBNET_RG_BUDGET_MS=1 bash "$HERE/vbnet-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-dotnet env VBNET_DOTNET_CONFIG_ONLY=1 bash "$HERE/vbnet-dotnet-gate.sh" "$ROOT/testdata/good" &
probe dotnet-missing env VBNET_DOTNET_CONFIG_ONLY=1 bash "$HERE/vbnet-dotnet-gate.sh" "$ROOT/testdata/dotnet-missing" &
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
check_fail tight-hot "hotpath budget fails when VBNET_RG_BUDGET_MS=1"
check_pass good-dotnet "dotnet passes on good (config)"
check_fail dotnet-missing "dotnet fails without wiring"

require_grep "$HERE/vbnet-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/vbnet-hotpath-gate.sh" 'VBNET_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/vbnet-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.vb" 'On Error Resume Next' "bad fixture encodes On Error Resume Next"
require_grep "$ROOT/testdata/bad/smell.vb" 'Option Strict Off' "bad fixture encodes Option Strict Off"
require_grep "$ROOT/testdata/bad/smell.vb" 'Console\.WriteLine' "bad fixture encodes Console.WriteLine"
require_grep "$ROOT/testdata/good/ok.vb" 'vbnet-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/OkLib.vbproj" 'OptionStrict|Sdk' "good encodes vbproj"
require_grep "$ROOT/templates/no_on_error_resume_next.vb" 'Try|Catch' "no_on_error template encodes Try/Catch"
require_grep "$ROOT/templates/option_strict_on.vb" 'Option Strict On' "option_strict_on template encodes Strict On"
require_grep "$ROOT/templates/logger_not_console.vb" 'ILogger|LogInformation' "logger_not_console template encodes logging"

for f in no_on_error_resume_next.vb option_strict_on.vb logger_not_console.vb github-workflows/vbnet-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS vbnet-kit-selfcheck"
