#!/usr/bin/env bash
# Tier 0: Programming Standards Reference CSS smells (portable regex bar).
# PSR: stylelint lint; no !important abuse; no universal selector hotpath;
# no expression()/behavior IE smells.
# Language-farm. Product stylelint remains authoritative for depth; this gate is
# the portable rg bar for CSS trust / perf smells.
#
# Usage: bash scripts/css-rg-gate.sh [root] [path ...]
# Default scan: CSS_RG_SRC or . Escape hatch: css-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for css-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${CSS_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${CSS_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(important_abuse universal_hotpath ie_expression_behavior)
SCAN_PATS=(
  '(?i)!important\b'
  '(?m)(?:^|[,\s>+~])\*(?=\s*[{,>+~.]|\s*$|\s*/\*)'
  '(?i)(\bexpression\s*\()|(\bbehavior\s*:)'
)
CLASS_PATS=(
  '(?i)!important\b'
  '(?m)(?:^|[,\s>+~])\*(?=\s*[{,>+~.]|\s*$|\s*/\*)'
  '(?i)(\bexpression\s*\()|(\bbehavior\s*:)'
)
MSGS=(
  '!important abuse banned (prefer specificity / @layer; css-rg-allow with rationale; stylelint declaration-no-important)'
  'Universal selector hotpath banned (bare * / .foo * / * *; prefer scoped reset; css-rg-allow with rationale; stylelint selector-max-universal)'
  'IE expression()/behavior smell banned (prefer modern CSS; css-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.css' --glob '*.CSS' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and CSS-comment-only hits (line is only a comment).
  rg -v 'css-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*/\*' >"$FILT" || true
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
echo "PASS css-rg-gate (${TARGETS[*]}, single-walk)"
