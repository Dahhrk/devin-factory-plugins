#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Go Template smells (portable regex bar).
# PSR: html/template over text/template for HTML (XSS); no Execute without
# context / discarded err; no missing FuncMap escaping; no nested template
# include of untrusted names.
# Language-farm. Product Go toolchain remains authoritative for compile/render;
# this gate is the portable rg bar for Go Template trust smells.
#
# Usage: bash scripts/gotemplate-rg-gate.sh [root] [path ...]
# Default scan: GOTEMPLATE_RG_SRC or . Escape hatch: gotemplate-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.go / *.tmpl / *.gotmpl / *.html.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for gotemplate-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${GOTEMPLATE_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${GOTEMPLATE_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
IDS=(text_template_html_xss execute_without_context missing_funcmap_escaping untrusted_template_name)
SCAN_PATS=(
  '"text/template"'
  '_\s*=\s*\w+\.Execute(Template)?\s*\('
  '(?i)template\.HTML\s*\(|"raw"\s*:|"safeHTML"\s*:|"unescaped"\s*:|"noescape"\s*:'
  '\{\{\s*template\s+\.|ExecuteTemplate\s*\([^,]+,\s*[a-zA-Z_][a-zA-Z0-9_\.]*\s*,'
)
CLASS_PATS=(
  '"text/template"'
  '_\s*=\s*\w+\.Execute(Template)?\s*\('
  '(?i)template\.HTML\s*\(|"raw"\s*:|"safeHTML"\s*:|"unescaped"\s*:|"noescape"\s*:'
  '\{\{\s*template\s+\.|ExecuteTemplate\s*\([^,]+,\s*[a-zA-Z_][a-zA-Z0-9_\.]*\s*,'
)

MSGS=(
  'text/template for HTML banned (XSS; prefer html/template; gotemplate-rg-allow with rationale)'
  'Execute without context / discarded err banned (_ = tmpl.Execute / ExecuteTemplate; prefer if err := ...; gotemplate-rg-allow with rationale)'
  'missing FuncMap escaping banned (template.HTML cast / raw|safeHTML|unescaped|noescape helpers; prefer contextual autoescape; gotemplate-rg-allow with rationale)'
  'nested template include of untrusted name banned ({{template .Name}} / ExecuteTemplate with non-literal name; prefer static string name; gotemplate-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.go' --glob '*.tmpl' --glob '*.gotmpl' --glob '*.html' --glob '*.HTML'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and Go/line-comment-only hits.
  rg -v 'gotemplate-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|/\*|\*)' >"$FILT" || true
else
  : >"$FILT"
fi

report_fail() {
  echo "FAIL: $1"
  head -40 "$2"
  local n; n=$(wc -l <"$2" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
}

classify_one() {
  local i="$1" id="${IDS[$i]}" cpat="${CLASS_PATS[$i]}"
  local hitfile="$TMPDIR_GATE/hit.$id" rcfile="$TMPDIR_GATE/rc.$id"
  : >"$hitfile"
  rg -P -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
  if [[ -s "$hitfile" ]]; then echo 1 >"$rcfile"; else echo 0 >"$rcfile"; fi
}

if [[ -s "$FILT" ]]; then
  pids=()
  for i in "${!IDS[@]}"; do classify_one "$i" & pids+=($!); done
  for pid in "${pids[@]}"; do wait "$pid" || true; done
  for i in "${!IDS[@]}"; do
    if [[ "$(cat "$TMPDIR_GATE/rc.${IDS[$i]}")" != "0" ]]; then
      report_fail "${MSGS[$i]}" "$TMPDIR_GATE/hit.${IDS[$i]}"
      fail=1
    fi
  done
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS gotemplate-rg-gate (${TARGETS[*]}, single-walk)"
