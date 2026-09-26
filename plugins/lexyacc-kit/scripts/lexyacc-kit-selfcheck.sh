#!/usr/bin/env bash
# Prove lexyacc-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/lexyacc-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/lexyacc-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/lexyacc-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env LEXYACC_RG_BUDGET_MS=1 bash "$HERE/lexyacc-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-tool env LEXYACC_TOOL_CONFIG_ONLY=1 bash "$HERE/lexyacc-tool-gate.sh" "$ROOT/testdata/good" &
probe tool-missing env LEXYACC_TOOL_CONFIG_ONLY=1 bash "$HERE/lexyacc-tool-gate.sh" "$ROOT/testdata/tool-missing" &
probe tool-weak env LEXYACC_TOOL_CONFIG_ONLY=1 bash "$HERE/lexyacc-tool-gate.sh" "$ROOT/testdata/tool-weak" &
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
check_fail tight-hot "hotpath budget fails when LEXYACC_RG_BUDGET_MS=1"
check_pass good-tool "tool passes on good (config)"
check_fail tool-missing "tool fails without wiring"
check_fail tool-weak "tool fails without lexyacc instructions / dep / CI"

require_grep "$HERE/lexyacc-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/lexyacc-hotpath-gate.sh" 'LEXYACC_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/lexyacc-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.l" '%include /tmp/' "bad fixture encodes untrusted %include"
require_grep "$ROOT/testdata/bad/smell.l" '#include </etc/' "bad fixture encodes untrusted #include"
require_grep "$ROOT/testdata/bad/smell.y" 'yyerror.*\{\s*\}|void yyerror' "bad fixture encodes yyerror silence"
require_grep "$ROOT/testdata/bad/smell.l" 'strcpy\(.*yytext' "bad fixture encodes unbounded yytext"
require_grep "$ROOT/testdata/bad/smell.l" 'char \*p = yytext' "bad fixture encodes unbounded yytext ptr"
require_grep "$ROOT/testdata/good/ok.l" '%include "rules.inc"' "good fixture encodes trusted include"
require_grep "$ROOT/testdata/good/ok.y" 'fprintf\(stderr' "good fixture encodes yyerror report"
require_grep "$ROOT/testdata/good/ok.l" 'snprintf|strncpy' "good fixture encodes bounded yytext"
require_grep "$ROOT/testdata/good/ok.l" 'yyleng' "good fixture encodes yyleng bound"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'flex|bison' "good CI encodes flex/bison"
require_grep "$ROOT/templates/trusted_include.l" '%include "rules.inc"' "trusted_include template encodes relative include"
require_grep "$ROOT/templates/yyerror_report.y" 'fprintf\(stderr' "yyerror_report template encodes stderr report"
require_grep "$ROOT/templates/bounded_yytext.l" 'snprintf|strncpy' "bounded_yytext template encodes snprintf/strncpy"
require_grep "$ROOT/templates/bounded_yytext_ptr.l" 'yyleng' "bounded_yytext_ptr template encodes yyleng"

for f in trusted_include.l yyerror_report.y bounded_yytext.l bounded_yytext_ptr.l github-workflows/lexyacc-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS lexyacc-kit-selfcheck"
