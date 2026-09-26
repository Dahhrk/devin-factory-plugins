#!/usr/bin/env bash
# Prove r-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/r-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/r-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/r-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env R_RG_BUDGET_MS=1 bash "$HERE/r-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-lintr env R_LINTR_CONFIG_ONLY=1 bash "$HERE/r-lintr-gate.sh" "$ROOT/testdata/good" &
probe lintr-missing env R_LINTR_CONFIG_ONLY=1 bash "$HERE/r-lintr-gate.sh" "$ROOT/testdata/lintr-missing" &
probe lintr-weak env R_LINTR_CONFIG_ONLY=1 bash "$HERE/r-lintr-gate.sh" "$ROOT/testdata/lintr-weak" &
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
check_fail tight-hot "hotpath budget fails when R_RG_BUDGET_MS=1"
check_pass good-lintr "lintr passes on good (config)"
check_fail lintr-missing "lintr fails without wiring"
check_fail lintr-weak "lintr fails without T_and_F_symbol_linter / undesirable_function_linter"

require_grep "$HERE/r-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/r-hotpath-gate.sh" 'R_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/r-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.R" 'attach\(' "bad fixture encodes attach"
require_grep "$ROOT/testdata/bad/smell.R" '<- T' "bad fixture encodes T symbol"
require_grep "$ROOT/testdata/bad/smell.R" 'eval\(parse\(' "bad fixture encodes eval(parse"
require_grep "$ROOT/testdata/good/ok.R" 'r-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/.lintr" 'T_and_F_symbol_linter' "good .lintr encodes T_and_F_symbol_linter"
require_grep "$ROOT/testdata/good/.lintr" 'undesirable_function_linter' "good .lintr encodes undesirable_function_linter"
require_grep "$ROOT/templates/no_attach.R" '::' "no_attach template encodes pkg::fun"
require_grep "$ROOT/templates/true_false_not_tf.R" 'TRUE' "true_false_not_tf template encodes TRUE"
require_grep "$ROOT/templates/no_eval_parse.R" 'get\(' "no_eval_parse template encodes get("

for f in no_attach.R true_false_not_tf.R no_eval_parse.R .lintr github-workflows/r-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS r-kit-selfcheck"
