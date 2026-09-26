#!/usr/bin/env bash
# Prove fortran-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/fortran-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/fortran-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/fortran-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env FORTRAN_RG_BUDGET_MS=1 bash "$HERE/fortran-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fort env FORTRAN_FORTITUDE_CONFIG_ONLY=1 bash "$HERE/fortran-fortitude-gate.sh" "$ROOT/testdata/good" &
probe fort-missing env FORTRAN_FORTITUDE_CONFIG_ONLY=1 bash "$HERE/fortran-fortitude-gate.sh" "$ROOT/testdata/fortitude-missing" &
probe fort-weak env FORTRAN_FORTITUDE_CONFIG_ONLY=1 bash "$HERE/fortran-fortitude-gate.sh" "$ROOT/testdata/fortitude-weak" &
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
check_fail tight-hot "hotpath budget fails when FORTRAN_RG_BUDGET_MS=1"
check_pass good-fort "fortitude passes on good (config)"
check_fail fort-missing "fortitude fails without wiring"
check_fail fort-weak "fortitude fails when C001 / implicit-typing ignored"

require_grep "$HERE/fortran-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/fortran-hotpath-gate.sh" 'FORTRAN_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/fortran-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.f90" 'implicit real' "bad fixture encodes old-style implicit"
require_grep "$ROOT/testdata/bad/smell.f90" 'goto' "bad fixture encodes goto"
require_grep "$ROOT/testdata/bad/smell.f90" 'open \(10' "bad fixture encodes unchecked open"
require_grep "$ROOT/testdata/good/ok.f90" 'fortran-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/.fortitude.toml" 'C001|implicit-typing|select' "good .fortitude.toml encodes select / C rules"
require_grep "$ROOT/templates/implicit_none.f90" 'implicit none' "implicit_none template encodes implicit none"
require_grep "$ROOT/templates/no_goto.f90" 'select case' "no_goto template encodes select case"
require_grep "$ROOT/templates/checked_io.f90" 'iostat' "checked_io template encodes iostat"

for f in implicit_none.f90 no_goto.f90 checked_io.f90 .fortitude.toml github-workflows/fortran-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS fortran-kit-selfcheck"
