#!/usr/bin/env bash
# Tier 0: Programming Standards Reference HTML smells (portable regex bar).
# PSR: htmlhint lint; no missing alt; no inline JS/CSS smells; no external script
# without integrity where relevant.
# Language-farm. Product htmlhint remains authoritative for depth; this gate is
# the portable rg bar for HTML trust / a11y smells.
#
# Usage: bash scripts/html-rg-gate.sh [root] [path ...]
# Default scan: HTML_RG_SRC or . Escape hatch: html-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for html-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${HTML_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${HTML_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(missing_alt inline_js_css script_no_integrity)
SCAN_PATS=(
  '(?i)<img\b(?![^>]*\balt\s*=)(?![^>]*\baria-hidden\s*=\s*["'"'"']?\s*true)[^>]*>'
  '(?i)(\sstyle\s*=)|(\son(click|dblclick|mousedown|mouseup|mouseover|mouseout|mousemove|mouseenter|mouseleave|keydown|keyup|keypress|load|unload|submit|reset|change|focus|blur|scroll|resize|error|message|select)\s*=)|((href|src)\s*=\s*["'"'"']?\s*javascript:)|(<script\b(?![^>]*\bsrc\s*=)[^>]*>)|(<style\b[^>]*>)'
  '(?i)<script\b(?=[^>]*\bsrc\s*=\s*["'"'"']https?://)(?![^>]*\bintegrity\s*=)[^>]*>'
)
CLASS_PATS=(
  '(?i)<img\b(?![^>]*\balt\s*=)(?![^>]*\baria-hidden\s*=\s*["'"'"']?\s*true)[^>]*>'
  '(?i)(\sstyle\s*=)|(\son(click|dblclick|mousedown|mouseup|mouseover|mouseout|mousemove|mouseenter|mouseleave|keydown|keyup|keypress|load|unload|submit|reset|change|focus|blur|scroll|resize|error|message|select)\s*=)|((href|src)\s*=\s*["'"'"']?\s*javascript:)|(<script\b(?![^>]*\bsrc\s*=)[^>]*>)|(<style\b[^>]*>)'
  '(?i)<script\b(?=[^>]*\bsrc\s*=\s*["'"'"']https?://)(?![^>]*\bintegrity\s*=)[^>]*>'
)
MSGS=(
  'Missing alt on <img> banned (prefer alt= or aria-hidden="true"; html-rg-allow with rationale; htmlhint alt-require)'
  'Inline JS/CSS smell banned (style=, on* handlers, javascript: URLs, inline <script>/<style>; prefer external assets; html-rg-allow with rationale; htmlhint inline-script-disabled / inline-style-disabled)'
  'External <script src="https?://…"> without integrity banned where relevant (prefer SRI integrity= + crossorigin; html-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.html' --glob '*.htm' --glob '*.HTML' --glob '*.HTM' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and HTML-comment-only hits (line is only a comment).
  rg -v 'html-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*<!--' >"$FILT" || true
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
echo "PASS html-rg-gate (${TARGETS[*]}, single-walk)"
