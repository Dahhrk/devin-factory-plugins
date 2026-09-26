#!/usr/bin/env bash
# Prove html-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/html-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/html-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/html-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env HTML_RG_BUDGET_MS=1 bash "$HERE/html-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-htmlhint env HTML_HTMLHINT_CONFIG_ONLY=1 bash "$HERE/html-htmlhint-gate.sh" "$ROOT/testdata/good" &
probe htmlhint-missing env HTML_HTMLHINT_CONFIG_ONLY=1 bash "$HERE/html-htmlhint-gate.sh" "$ROOT/testdata/htmlhint-missing" &
probe htmlhint-weak env HTML_HTMLHINT_CONFIG_ONLY=1 bash "$HERE/html-htmlhint-gate.sh" "$ROOT/testdata/htmlhint-weak" &
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
check_fail tight-hot "hotpath budget fails when HTML_RG_BUDGET_MS=1"
check_pass good-htmlhint "htmlhint passes on good (config)"
check_fail htmlhint-missing "htmlhint fails without wiring"
check_fail htmlhint-weak "htmlhint fails without alt-require / inline-script-disabled / inline-style-disabled"

require_grep "$HERE/html-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/html-hotpath-gate.sh" 'HTML_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/html-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.html" '<img[^>]*src=' "bad fixture encodes missing-alt img"
require_grep "$ROOT/testdata/bad/smell.html" 'style=' "bad fixture encodes inline style"
require_grep "$ROOT/testdata/bad/smell.html" 'onclick=' "bad fixture encodes inline script handler"
require_grep "$ROOT/testdata/bad/smell.html" 'script[^>]+src="https?://' "bad fixture encodes external script"
require_grep "$ROOT/testdata/good/ok.html" 'html-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/.htmlhintrc" 'alt-require' "good .htmlhintrc encodes alt-require"
require_grep "$ROOT/testdata/good/.htmlhintrc" 'inline-script-disabled' "good .htmlhintrc encodes inline-script-disabled"
require_grep "$ROOT/testdata/good/.htmlhintrc" 'inline-style-disabled' "good .htmlhintrc encodes inline-style-disabled"
require_grep "$ROOT/templates/accessible_img.html" 'alt=' "accessible_img template encodes alt"
require_grep "$ROOT/templates/external_script_sri.html" 'integrity=' "external_script_sri template encodes integrity"

for f in accessible_img.html external_script_sri.html .htmlhintrc github-workflows/html-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS html-kit-selfcheck"
