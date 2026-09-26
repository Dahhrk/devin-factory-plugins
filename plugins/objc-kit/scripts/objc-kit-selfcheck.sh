#!/usr/bin/env bash
# Prove objc-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/objc-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/objc-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/objc-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env OBJC_RG_BUDGET_MS=1 bash "$HERE/objc-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env OBJC_FMT_CONFIG_ONLY=1 bash "$HERE/objc-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env OBJC_FMT_CONFIG_ONLY=1 bash "$HERE/objc-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
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
check_fail tight-hot "hotpath budget fails when OBJC_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without wiring"

require_grep "$HERE/objc-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/objc-hotpath-gate.sh" 'OBJC_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/objc-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/Smell.m" 'NSLog' "bad fixture encodes NSLog"
require_grep "$ROOT/testdata/bad/Smell.m" 'performSelector' "bad fixture encodes performSelector"
require_grep "$ROOT/testdata/bad/Smell.m" 'retain|release|autorelease' "bad fixture encodes manual retain/release/autorelease"
require_grep "$ROOT/testdata/good/Ok.m" 'objc-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/.clang-format" 'BasedOnStyle|IndentWidth' "good encodes clang-format"
require_grep "$ROOT/templates/no_nslog.m" 'NSLog' "no_nslog template names the ban"
require_grep "$ROOT/templates/no_perform_selector.m" 'performSelector' "no_perform_selector template names the ban"
require_grep "$ROOT/templates/no_manual_retain.m" 'retain|release|autorelease' "no_manual_retain template names the ban"
require_grep "$ROOT/templates/.clang-format" 'BasedOnStyle' "clang-format template present"

for f in no_nslog.m no_perform_selector.m no_manual_retain.m .clang-format github-workflows/objc-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS objc-kit-selfcheck"
