#!/usr/bin/env bash
# Prove apps-script-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/apps-script-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/apps-script-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/apps-script-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env APPS_SCRIPT_RG_BUDGET_MS=1 bash "$HERE/apps-script-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-clasp env APPS_SCRIPT_CLASP_CONFIG_ONLY=1 bash "$HERE/apps-script-clasp-gate.sh" "$ROOT/testdata/good" &
probe clasp-missing env APPS_SCRIPT_CLASP_CONFIG_ONLY=1 bash "$HERE/apps-script-clasp-gate.sh" "$ROOT/testdata/apps-script-missing" &
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
check_fail tight-hot "hotpath budget fails when APPS_SCRIPT_RG_BUDGET_MS=1"
check_pass good-clasp "clasp passes on good (config)"
check_fail clasp-missing "clasp fails without wiring"

require_grep "$HERE/apps-script-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/apps-script-hotpath-gate.sh" 'APPS_SCRIPT_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/apps-script-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.gs" 'eval\s*\(' "bad fixture encodes eval"
require_grep "$ROOT/testdata/bad/smell.gs" 'Logger\.log' "bad fixture encodes Logger.log"
require_grep "$ROOT/testdata/bad/smell.gs" 'getUi' "bad fixture encodes getUi"
require_grep "$ROOT/testdata/bad/smell.gs" 'appendRow' "bad fixture encodes concurrent write without lock"
require_grep "$ROOT/testdata/good/WebApp.gs" 'LockService' "good fixture encodes LockService"
require_grep "$ROOT/testdata/good/Menu.gs" 'getUi' "good fixture encodes container getUi"
require_grep "$ROOT/testdata/good/.clasp.json" 'scriptId' "good encodes clasp"
require_grep "$ROOT/testdata/good/appsscript.json" 'runtimeVersion' "good encodes appsscript.json"
require_grep "$ROOT/templates/no_eval.gs" 'JSON\.parse|parsePayload_' "no_eval template encodes parse"
require_grep "$ROOT/templates/no_logger_log.gs" 'summarizeRows_|return' "no_logger_log template encodes return"
require_grep "$ROOT/templates/no_getui_in_webapp.gs" 'HtmlService' "no_getui_in_webapp template encodes HtmlService"
require_grep "$ROOT/templates/lock_concurrent_write.gs" 'LockService' "lock_concurrent_write template encodes LockService"

# no_eval must not call eval/new Function
if rg -n -P '(?i)\beval\s*\(|\bnew\s+Function\s*\(' "$ROOT/templates/no_eval.gs" >/dev/null 2>&1; then
  echo "FAIL selfcheck: no_eval.gs still has eval/new Function"; fail=1
else
  echo "ok: no_eval.gs has no eval/new Function"
fi

# no_logger_log must not call Logger.log
if rg -n -P '(?i)\bLogger\.log\s*\(' "$ROOT/templates/no_logger_log.gs" >/dev/null 2>&1; then
  echo "FAIL selfcheck: no_logger_log.gs still has Logger.log"; fail=1
else
  echo "ok: no_logger_log.gs has no Logger.log"
fi


require_grep "$ROOT/templates/onopen_menu.gs" 'onOpen' "onopen_menu template encodes onOpen"

for f in no_eval.gs no_logger_log.gs no_getui_in_webapp.gs onopen_menu.gs lock_concurrent_write.gs github-workflows/apps-script-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS apps-script-kit-selfcheck"
