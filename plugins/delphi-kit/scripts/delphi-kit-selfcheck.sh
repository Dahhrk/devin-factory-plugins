#!/usr/bin/env bash
# Prove delphi-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/delphi-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/delphi-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/delphi-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env DELPHI_RG_BUDGET_MS=1 bash "$HERE/delphi-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fpc env DELPHI_FPC_CONFIG_ONLY=1 bash "$HERE/delphi-fpc-gate.sh" "$ROOT/testdata/good" &
probe fpc-missing env DELPHI_FPC_CONFIG_ONLY=1 bash "$HERE/delphi-fpc-gate.sh" "$ROOT/testdata/fpc-missing" &
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
check_fail tight-hot "hotpath budget fails when DELPHI_RG_BUDGET_MS=1"
check_pass good-fpc "fpc passes on good (config)"
check_fail fpc-missing "fpc fails without wiring"

require_grep "$HERE/delphi-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/delphi-hotpath-gate.sh" 'DELPHI_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/delphi-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.pas" 'goto' "bad fixture encodes goto"
require_grep "$ROOT/testdata/bad/smell.pas" 'with ' "bad fixture encodes with-statement"
require_grep "$ROOT/testdata/bad/smell.pas" 'GetMem' "bad fixture encodes GetMem"
require_grep "$ROOT/testdata/bad/smell.pas" 'WriteLn|Writeln|writeln' "bad fixture encodes WriteLn"
require_grep "$ROOT/testdata/good/ok.pas" 'delphi-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/Makefile" 'fpc|lazbuild' "good encodes fpc Makefile"
require_grep "$ROOT/templates/no_goto.pas" 'Exit|for |while |repeat' "no_goto template encodes structured control"
require_grep "$ROOT/templates/no_with.pas" 'with' "no_with template names the ban"
require_grep "$ROOT/templates/checked_getmem.pas" 'GetMem|New\(' "checked_getmem template encodes alloc"
require_grep "$ROOT/templates/no_writeln_lib.pas" 'WriteLn|logging|Result' "no_writeln_lib template encodes lib logging"

for f in no_goto.pas no_with.pas checked_getmem.pas no_writeln_lib.pas github-workflows/delphi-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS delphi-kit-selfcheck"
