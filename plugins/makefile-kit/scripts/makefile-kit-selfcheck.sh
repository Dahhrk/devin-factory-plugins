#!/usr/bin/env bash
# Prove makefile-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/makefile-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/makefile-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/makefile-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env MAKEFILE_RG_BUDGET_MS=1 bash "$HERE/makefile-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-make env MAKEFILE_MAKE_CONFIG_ONLY=1 bash "$HERE/makefile-make-gate.sh" "$ROOT/testdata/good" &
probe make-missing env MAKEFILE_MAKE_CONFIG_ONLY=1 bash "$HERE/makefile-make-gate.sh" "$ROOT/testdata/make-missing" &
probe make-weak env MAKEFILE_MAKE_CONFIG_ONLY=1 bash "$HERE/makefile-make-gate.sh" "$ROOT/testdata/make-weak" &
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
check_fail tight-hot "hotpath budget fails when MAKEFILE_RG_BUDGET_MS=1"
check_pass good-make "make passes on good (config)"
check_fail make-missing "make fails without wiring"
check_fail make-weak "make fails without Makefile instructions / dep / CI"

require_grep "$HERE/makefile-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/makefile-hotpath-gate.sh" 'MAKEFILE_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/makefile-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.mk" '\$\(MAKE\)' "bad fixture encodes recursive MAKE"
require_grep "$ROOT/testdata/bad/smells.mk" '\$\(shell' "bad fixture encodes \$(shell)"
require_grep "$ROOT/testdata/bad/smells.mk" 'include \$\{|include \$\(' "bad fixture encodes include(\${"
require_grep "$ROOT/testdata/bad/smells.mk" '\.ONESHELL' "bad fixture encodes .ONESHELL"
require_grep "$ROOT/testdata/bad/smells.mk" 'curl.*\|.*bash|curl.*\| bash' "bad fixture encodes curl|bash"
require_grep "$ROOT/testdata/good/Makefile" '\.PHONY' "good fixture encodes .PHONY"
require_grep "$ROOT/testdata/good/ok.mk" 'include rules\.mk' "good fixture encodes static include"
require_grep "$ROOT/testdata/good/ok.mk" 'VERSION :=' "good fixture encodes explicit VERSION"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'make' "good CI encodes make"
require_grep "$ROOT/templates/phony_recursive.mk" '\.PHONY' "phony_recursive template encodes .PHONY"
require_grep "$ROOT/templates/tab_recipes.mk" 'cc -o app' "tab_recipes template encodes recipe"
require_grep "$ROOT/templates/no_unchecked_shell.mk" 'VERSION :=' "no_unchecked_shell template encodes VERSION"
require_grep "$ROOT/templates/trusted_static_include.mk" 'include rules\.mk' "trusted_static_include template encodes static include"
require_grep "$ROOT/templates/no_oneshell_curl_bash.mk" 'install\.sh' "no_oneshell_curl_bash template encodes install.sh"

for f in phony_recursive.mk tab_recipes.mk no_unchecked_shell.mk trusted_static_include.mk no_oneshell_curl_bash.mk github-workflows/makefile-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS makefile-kit-selfcheck"
