#!/usr/bin/env bash
# Tier 0: Programming Standards Reference React smells (portable regex bar).
# PSR: react wiring; no dangerouslySetInnerHTML without sanitize; no findDOMNode;
# no ReactDOM.render (prefer createRoot).
# Language-farm. Product React remains authoritative for build/test; this gate
# is the portable rg bar for React trust smells.
#
# Usage: bash scripts/react-rg-gate.sh [root] [path ...]
# Default scan: REACT_RG_SRC or . Escape hatch: react-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.jsx / *.tsx / *.js / *.ts.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for react-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${REACT_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${REACT_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

IDS=(dangerously_html find_dom_node reactdom_render)
SCAN_PATS=(
  '(?i)\bdangerouslySetInnerHTML\b'
  '(?i)\bfindDOMNode\b'
  '(?i)\bReactDOM\s*\.\s*render\s*\('
)
CLASS_PATS=(
  '(?i)\bdangerouslySetInnerHTML\b'
  '(?i)\bfindDOMNode\b'
  '(?i)\bReactDOM\s*\.\s*render\s*\('
)
MSGS=(
  'dangerouslySetInnerHTML without sanitize banned (prefer JSX children or DOMPurify.sanitize / sanitizeHtml / .sanitize( on the same line; react-rg-allow with rationale)'
  'findDOMNode banned (prefer refs / callback refs; react-rg-allow with rationale)'
  'ReactDOM.render banned (prefer createRoot(...).render; react-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.jsx' --glob '*.tsx' --glob '*.js' --glob '*.ts' --glob '*.JSX' --glob '*.TSX' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**' --glob '!**/__tests__/**' --glob '!**/packages/react-dom/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'react-rg-allow' "$ALL" 2>/dev/null \
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
  if [[ "$id" == "dangerously_html" && -s "$hitfile" ]]; then
    local kept="$TMPDIR_GATE/hit.dangerously_html.kept"
    rg -v -P '(?i)(DOMPurify\.sanitize|sanitizeHtml|\.sanitize\s*\(|(?<![\w.])sanitize\s*\()' "$hitfile" >"$kept" 2>/dev/null || true
    mv "$kept" "$hitfile"
  fi
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
echo "PASS react-rg-gate (${TARGETS[*]}, single-walk)"
