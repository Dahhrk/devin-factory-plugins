#!/usr/bin/env bash
# Prove cobol-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/cobol-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/cobol-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/cobol-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env COBOL_RG_BUDGET_MS=1 bash "$HERE/cobol-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-cobc env COBOL_COBC_CONFIG_ONLY=1 bash "$HERE/cobol-cobc-gate.sh" "$ROOT/testdata/good" &
probe cobc-missing env COBOL_COBC_CONFIG_ONLY=1 bash "$HERE/cobol-cobc-gate.sh" "$ROOT/testdata/cobc-missing" &
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
check_fail tight-hot "hotpath budget fails when COBOL_RG_BUDGET_MS=1"
check_pass good-cobc "cobc passes on good (config)"
check_fail cobc-missing "cobc fails without wiring"

require_grep "$HERE/cobol-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/cobol-hotpath-gate.sh" 'COBOL_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/cobol-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.cob" 'GO TO|GOTO|go to' "bad fixture encodes GOTO"
require_grep "$ROOT/testdata/bad/smell.cob" 'ALTER' "bad fixture encodes ALTER"
require_grep "$ROOT/testdata/bad/smell.cob" 'ACCEPT' "bad fixture encodes ACCEPT"
require_grep "$ROOT/testdata/bad/smell.cob" 'IF WS-FLAG' "bad fixture encodes IF without END-IF"
require_grep "$ROOT/testdata/good/ok.cob" 'cobol-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/Makefile" 'cobc' "good encodes cobc Makefile"
require_grep "$ROOT/templates/no_goto.cob" 'PERFORM|EVALUATE' "no_goto template encodes structured control"
require_grep "$ROOT/templates/no_alter.cob" 'ALTER' "no_alter template names the ban"
require_grep "$ROOT/templates/checked_accept.cob" 'ON EXCEPTION' "checked_accept template encodes ON EXCEPTION"
require_grep "$ROOT/templates/end_if.cob" 'END-IF' "end_if template encodes END-IF"

for f in no_goto.cob no_alter.cob checked_accept.cob end_if.cob github-workflows/cobol-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS cobol-kit-selfcheck"
