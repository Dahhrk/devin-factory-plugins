#!/usr/bin/env bash
# Prove ada-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/ada-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/ada-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/ada-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env ADA_RG_BUDGET_MS=1 bash "$HERE/ada-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-gnat env ADA_GNAT_CONFIG_ONLY=1 bash "$HERE/ada-gnat-gate.sh" "$ROOT/testdata/good" &
probe gnat-missing env ADA_GNAT_CONFIG_ONLY=1 bash "$HERE/ada-gnat-gate.sh" "$ROOT/testdata/gnat-missing" &
probe gnat-weak env ADA_GNAT_CONFIG_ONLY=1 bash "$HERE/ada-gnat-gate.sh" "$ROOT/testdata/gnat-weak" &
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
check_fail tight-hot "hotpath budget fails when ADA_RG_BUDGET_MS=1"
check_pass good-gnat "gnat passes on good (config)"
check_fail gnat-missing "gnat fails without wiring"
check_fail gnat-weak "gnat fails when rules disable Unchecked_Conversions / weak gpr"

require_grep "$HERE/ada-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/ada-hotpath-gate.sh" 'ADA_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/ada-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.adb" 'Unchecked_Conversion' "bad fixture encodes Unchecked_Conversion"
require_grep "$ROOT/testdata/bad/smell.adb" 'pragma Suppress' "bad fixture encodes pragma Suppress"
require_grep "$ROOT/testdata/good/ok.adb" 'ada-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/product.gpr" 'Pretty_Printer|package Check' "good gpr encodes gnatpp/gnatcheck"
require_grep "$ROOT/templates/no_unchecked_conversion.ads" 'Unchecked_Conversion' "no_unchecked_conversion template names the ban"
require_grep "$ROOT/templates/no_suppress.adb" 'Suppress' "no_suppress template names the ban"
require_grep "$ROOT/templates/gnatcheck.rules" 'Unchecked_Conversions' "gnatcheck.rules enables Unchecked_Conversions"

for f in no_unchecked_conversion.ads no_suppress.adb gnatcheck_boundary.ads product.gpr gnatcheck.rules github-workflows/ada-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ada-kit-selfcheck"
