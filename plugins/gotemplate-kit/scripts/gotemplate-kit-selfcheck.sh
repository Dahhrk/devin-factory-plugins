#!/usr/bin/env bash
# Prove gotemplate-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/gotemplate-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/gotemplate-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/gotemplate-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env GOTEMPLATE_RG_BUDGET_MS=1 bash "$HERE/gotemplate-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-html env GOTEMPLATE_HTML_CONFIG_ONLY=1 bash "$HERE/gotemplate-html-gate.sh" "$ROOT/testdata/good" &
probe html-missing env GOTEMPLATE_HTML_CONFIG_ONLY=1 bash "$HERE/gotemplate-html-gate.sh" "$ROOT/testdata/gotemplate-missing" &
probe html-weak env GOTEMPLATE_HTML_CONFIG_ONLY=1 bash "$HERE/gotemplate-html-gate.sh" "$ROOT/testdata/gotemplate-weak" &
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
check_fail tight-hot "hotpath budget fails when GOTEMPLATE_RG_BUDGET_MS=1"
check_pass good-html "html passes on good (config)"
check_fail html-missing "html fails without wiring"
check_fail html-weak "html fails without html/template import / CI"

require_grep "$HERE/gotemplate-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/gotemplate-hotpath-gate.sh" 'GOTEMPLATE_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/gotemplate-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.go" 'text/template' "bad fixture encodes text/template"
require_grep "$ROOT/testdata/bad/smells.go" '_ = t.Execute' "bad fixture encodes discarded Execute"
require_grep "$ROOT/testdata/bad/smells.go" '"raw"' "bad fixture encodes raw FuncMap"
require_grep "$ROOT/testdata/bad/smells.go" 'ExecuteTemplate\(w, name' "bad fixture encodes untrusted ExecuteTemplate name"
require_grep "$ROOT/testdata/bad/smells.tmpl" '\{\{template \.' "bad fixture encodes {{template .Name}}"
require_grep "$ROOT/testdata/good/ok.go" 'gotemplate-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/ok.go" 'html/template' "good fixture encodes html/template"
require_grep "$ROOT/testdata/good/go.mod" 'module ' "good go.mod encodes module"
require_grep "$ROOT/templates/html_template_import.go" 'html/template' "html_template_import template encodes html/template"
require_grep "$ROOT/templates/execute_with_err.go" 'if err :=' "execute_with_err template encodes err check"
require_grep "$ROOT/templates/funcmap_escaped.go" 'html/template' "funcmap_escaped template encodes html/template"
require_grep "$ROOT/templates/static_template_name.go" 'ExecuteTemplate' "static_template_name template encodes ExecuteTemplate"

for f in html_template_import.go execute_with_err.go funcmap_escaped.go static_template_name.go github-workflows/gotemplate-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS gotemplate-kit-selfcheck"
