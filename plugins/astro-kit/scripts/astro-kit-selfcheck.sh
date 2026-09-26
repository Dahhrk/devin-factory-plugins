#!/usr/bin/env bash
# Prove astro-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/astro-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/astro-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/astro-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env ASTRO_RG_BUDGET_MS=1 bash "$HERE/astro-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-astro env ASTRO_ASTRO_CONFIG_ONLY=1 bash "$HERE/astro-astro-gate.sh" "$ROOT/testdata/good" &
probe astro-missing env ASTRO_ASTRO_CONFIG_ONLY=1 bash "$HERE/astro-astro-gate.sh" "$ROOT/testdata/astro-missing" &
probe astro-weak env ASTRO_ASTRO_CONFIG_ONLY=1 bash "$HERE/astro-astro-gate.sh" "$ROOT/testdata/astro-weak" &
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
check_fail tight-hot "hotpath budget fails when ASTRO_RG_BUDGET_MS=1"
check_pass good-astro "astro passes on good (config)"
check_fail astro-missing "astro fails without wiring"
check_fail astro-weak "astro fails without package.json astro / CI astro"

require_grep "$HERE/astro-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/astro-hotpath-gate.sh" 'ASTRO_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/astro-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.astro" 'client:load' "bad fixture encodes client:load"
require_grep "$ROOT/testdata/bad/smell.astro" 'set:html' "bad fixture encodes set:html"
require_grep "$ROOT/testdata/bad/smell.astro" 'define:vars' "bad fixture encodes define:vars"
require_grep "$ROOT/testdata/good/ok.astro" 'astro-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/ok.astro" 'DOMPurify.sanitize' "good fixture encodes sanitized set:html"
require_grep "$ROOT/testdata/good/package.json" '"astro"' "good package.json encodes astro dep"
require_grep "$ROOT/templates/client_visible_not_load.astro" 'client:visible' "client_visible_not_load template encodes client:visible"
require_grep "$ROOT/templates/set_html_sanitized.astro" 'DOMPurify.sanitize' "set_html_sanitized template encodes sanitize"
require_grep "$ROOT/templates/data_attrs_not_define_vars.astro" 'data-' "data_attrs_not_define_vars template encodes data-*"

for f in client_visible_not_load.astro set_html_sanitized.astro data_attrs_not_define_vars.astro github-workflows/astro-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS astro-kit-selfcheck"
