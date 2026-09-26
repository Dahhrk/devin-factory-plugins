#!/usr/bin/env bash
# Prove shell-kit gates discriminate fixtures (pack maturity).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
fail=0

probe() {
  local id="$1"
  shift
  if "$@" >"$WORKDIR/$id.out" 2>&1; then echo 0 >"$WORKDIR/$id.rc"; else echo 1 >"$WORKDIR/$id.rc"; fi
}

expect_fail() {
  local id="$1" label="$2"
  shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"
    cat "$WORKDIR/$id.out"
    fail=1
  else
    echo "ok: $label"
  fi
}

expect_pass() {
  local id="$1" label="$2"
  shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"
    cat "$WORKDIR/$id.out"
    fail=1
  else
    echo "ok: $label"
  fi
}

require_grep() {
  local file="$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]] || ! grep -q -E -e "$pat" -- "$file"; then
    echo "FAIL selfcheck: $label"
    fail=1
  else
    echo "ok: $label"
  fi
}

expect_fail bad-rg "rg fails on bad" bash "$HERE/sh-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/sh-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/sh-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when SH_RG_BUDGET_MS=1" env SH_RG_BUDGET_MS=1 bash "$HERE/sh-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good" bash "$HERE/sh-fmt-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-sc "shellcheck passes on good" bash "$HERE/sh-shellcheck-gate.sh" "$ROOT/testdata/good" . &
wait

expect_pass good-strict "strict-gate passes on good" bash "$HERE/sh-strict-gate.sh" "$ROOT/testdata/good" .
expect_fail strict-missing "strict-gate fails without set -euo" bash "$HERE/sh-strict-gate.sh" "$ROOT/testdata/strict-missing" .
expect_pass good-test "test-gate passes on good" bash "$HERE/sh-test-gate.sh" "$ROOT/testdata/good"
expect_fail test-missing "test-gate fails without tests" bash "$HERE/sh-test-gate.sh" "$ROOT/testdata/test-missing"

# config-only shellcheck against empty root lacking .shellcheckrc
TMP=$(mktemp -d)
expect_fail sc-config-missing "shellcheck config-only fails when missing" env SH_SHELLCHECK_CONFIG_ONLY=1 bash "$HERE/sh-shellcheck-gate.sh" "$TMP"
# need a .sh file for the gate to get past empty-files check — add one
printf '#!/bin/sh\n' >"$TMP/x.sh"
expect_fail sc-config-missing2 "shellcheck config-only fails without rc" env SH_SHELLCHECK_CONFIG_ONLY=1 bash "$HERE/sh-shellcheck-gate.sh" "$TMP"
cp "$ROOT/templates/shellcheck/shellcheckrc" "$TMP/.shellcheckrc"
expect_pass sc-config "shellcheck config-only passes with template rc" env SH_SHELLCHECK_CONFIG_ONLY=1 bash "$HERE/sh-shellcheck-gate.sh" "$TMP"
rm -rf "$TMP"

require_grep "$HERE/sh-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/sh-hotpath-gate.sh" 'SH_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/sh-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.sh" 'eval ' "bad fixture encodes eval"
require_grep "$ROOT/testdata/bad/smell.sh" '/tmp/.*\$\$' "bad fixture encodes unsafe temp"
require_grep "$ROOT/testdata/bad/smell.sh" 'for .+ in \$' "bad fixture encodes unquoted for"
require_grep "$ROOT/testdata/bad/smell.sh" 'cd \$' "bad fixture encodes unquoted cd"
require_grep "$ROOT/testdata/bad/smell.sh" 'rm -rf \$' "bad fixture encodes unquoted rm"
require_grep "$ROOT/testdata/bad/smell.sh" '\| sh' "bad fixture encodes curl|sh"
require_grep "$ROOT/testdata/good/ok.sh" 'set -euo pipefail' "good fixture encodes strict set"
require_grep "$ROOT/testdata/good/ok.sh" 'mktemp' "good fixture encodes mktemp"
require_grep "$ROOT/templates/safe_temp.sh" 'mktemp' "safe_temp template encodes mktemp"
require_grep "$ROOT/templates/quoted_expand.sh" '"\$\{files\[@\]\}"|"\$@"' "quoted_expand template encodes quoted arrays"
require_grep "$ROOT/templates/test_edge.sh" 'spaces' "test_edge template encodes filename spaces"
require_grep "$ROOT/templates/shellcheck/shellcheckrc" 'shell=bash' "shellcheckrc template encodes shell=bash"

for f in safe_temp.sh quoted_expand.sh test_edge.sh shellcheck/shellcheckrc github-workflows/sh-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"
    fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS sh-kit-selfcheck"
