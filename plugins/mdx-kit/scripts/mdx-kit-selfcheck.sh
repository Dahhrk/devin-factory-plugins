#!/usr/bin/env bash
# Prove mdx-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/mdx-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/mdx-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/mdx-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env MDX_RG_BUDGET_MS=1 bash "$HERE/mdx-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-mdx env MDX_MDX_CONFIG_ONLY=1 bash "$HERE/mdx-mdx-gate.sh" "$ROOT/testdata/good" &
probe mdx-missing env MDX_MDX_CONFIG_ONLY=1 bash "$HERE/mdx-mdx-gate.sh" "$ROOT/testdata/mdx-missing" &
probe mdx-weak env MDX_MDX_CONFIG_ONLY=1 bash "$HERE/mdx-mdx-gate.sh" "$ROOT/testdata/mdx-weak" &
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
check_fail tight-hot "hotpath budget fails when MDX_RG_BUDGET_MS=1"
check_pass good-mdx "mdx passes on good (config)"
check_fail mdx-missing "mdx fails without wiring"
check_fail mdx-weak "mdx fails without package.json @mdx-js / CI mdx"

require_grep "$HERE/mdx-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/mdx-hotpath-gate.sh" 'MDX_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/mdx-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.mdx" 'dangerouslySetInnerHTML' "bad fixture encodes dangerouslySetInnerHTML"
require_grep "$ROOT/testdata/bad/smell.mjs" 'evaluate' "bad fixture encodes evaluate"
require_grep "$ROOT/testdata/bad/smell.mjs" 'rehypeRaw' "bad fixture encodes rehype-raw"
require_grep "$ROOT/testdata/good/ok.mdx" 'mdx-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/pipeline.mjs" 'rehype-sanitize' "good fixture encodes rehype-sanitize with rehype-raw"
require_grep "$ROOT/testdata/good/package.json" '@mdx-js/mdx' "good package.json encodes @mdx-js/mdx dep"
require_grep "$ROOT/templates/no_dangerously_set_inner_html.mdx" 'children' "no_dangerously_set_inner_html template encodes children path"
require_grep "$ROOT/templates/trusted_static_mdx_import.mjs" "from './" "trusted_static_mdx_import template encodes static import"
require_grep "$ROOT/templates/rehype_raw_with_sanitize.mjs" 'rehype-sanitize' "rehype_raw_with_sanitize template encodes sanitize"

for f in no_dangerously_set_inner_html.mdx trusted_static_mdx_import.mjs rehype_raw_with_sanitize.mjs github-workflows/mdx-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS mdx-kit-selfcheck"
