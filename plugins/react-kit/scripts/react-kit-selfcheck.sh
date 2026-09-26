#!/usr/bin/env bash
# Prove react-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/react-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/react-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/react-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env REACT_RG_BUDGET_MS=1 bash "$HERE/react-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-react env REACT_REACT_CONFIG_ONLY=1 bash "$HERE/react-react-gate.sh" "$ROOT/testdata/good" &
probe react-missing env REACT_REACT_CONFIG_ONLY=1 bash "$HERE/react-react-gate.sh" "$ROOT/testdata/react-missing" &
probe react-weak env REACT_REACT_CONFIG_ONLY=1 bash "$HERE/react-react-gate.sh" "$ROOT/testdata/react-weak" &
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
check_fail tight-hot "hotpath budget fails when REACT_RG_BUDGET_MS=1"
check_pass good-react "react passes on good (config)"
check_fail react-missing "react fails without wiring"
check_fail react-weak "react fails without package.json react / CI"

require_grep "$HERE/react-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/react-hotpath-gate.sh" 'REACT_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/react-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.tsx" 'dangerouslySetInnerHTML' "bad fixture encodes dangerouslySetInnerHTML"
require_grep "$ROOT/testdata/bad/smell.tsx" 'findDOMNode' "bad fixture encodes findDOMNode"
require_grep "$ROOT/testdata/bad/smell.tsx" 'ReactDOM.render' "bad fixture encodes ReactDOM.render"
require_grep "$ROOT/testdata/good/ok.tsx" 'react-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/ok.tsx" 'DOMPurify.sanitize' "good fixture encodes sanitized html"
require_grep "$ROOT/testdata/good/ok.tsx" 'createRoot' "good fixture encodes createRoot"
require_grep "$ROOT/testdata/good/package.json" '"react"' "good package.json encodes react dep"
require_grep "$ROOT/templates/create_root_not_render.tsx" 'createRoot' "create_root_not_render template encodes createRoot"
require_grep "$ROOT/templates/sanitize_inner_html.tsx" 'DOMPurify.sanitize' "sanitize_inner_html template encodes sanitize"
require_grep "$ROOT/templates/ref_not_find_dom_node.tsx" 'useRef' "ref_not_find_dom_node template encodes useRef"

for f in create_root_not_render.tsx sanitize_inner_html.tsx ref_not_find_dom_node.tsx github-workflows/react-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS react-kit-selfcheck"
