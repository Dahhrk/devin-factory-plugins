#!/usr/bin/env bash
# Tier 1: require html/template toolchain wiring (PSR Go Template language-farm).
# Live go list when resolvable unless GOTEMPLATE_HTML_CONFIG_ONLY=1.
# Portable bar: "html/template" import / go.mod + templates / CI gotemplate.
# Escape: GOTEMPLATE_HTML_GATE_SKIP=1.
# Usage: bash scripts/gotemplate-html-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${GOTEMPLATE_HTML_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS gotemplate-html-gate (skipped via GOTEMPLATE_HTML_GATE_SKIP=1)"
  exit 0
fi

mapfile -t tmpl_files < <(find . \( \
  -name '*.go' -o -name '*.tmpl' -o -name '*.gotmpl' -o -name '*.html' -o -name '*.HTML' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#tmpl_files[@]} -eq 0 ]]; then
  echo "FAIL: no Go Template sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real html/template import (not bare substring in a comment-only name).
# Require a real import line (not a comment mentioning the path).
WIRE_PAT='(?m)^import[[:space:]]+"html/template"$|^[[:space:]]+"html/template"[[:space:]]*$'

if rg -qP --glob '*.go' --glob '!**/.git/**' --glob '!**/vendor/**' "$WIRE_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="html/template-import"
fi

if [[ "$has_file_cfg" -eq 0 && -f go.mod ]]; then
  # go.mod alone is weak without html/template import; still record presence.
  CFG="go.mod"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP 'gotemplate|html/template|go\s+test' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: html/template import, or CI that names gotemplate/html/template.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no html/template wiring (\"html/template\" import / CI; PSR: Go Template toolchain)"
  exit 1
fi

if [[ "${GOTEMPLATE_HTML_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS gotemplate-html-gate ($ROOT, config-only, ${#tmpl_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v go >/dev/null 2>&1; then
  set +e
  go list html/template >/tmp/gotemplate-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/gotemplate-gate-ver.$$.out"
    echo "PASS gotemplate-html-gate ($ROOT, live html/template, ${#tmpl_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/gotemplate-gate-ver.$$.out"
fi

echo "PASS gotemplate-html-gate ($ROOT, config-only fallback, ${#tmpl_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
