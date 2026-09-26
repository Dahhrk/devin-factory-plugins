#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Pug smells (portable regex bar).
# PSR: pug wiring; no unescaped buffered XSS (!= / !{}); no include of
# untrusted interpolated paths; no mixin injection (+#{name}).
# Language-farm. Product Pug toolchain remains authoritative for compile;
# this gate is the portable rg bar for Pug trust smells.
#
# Usage: bash scripts/pug-rg-gate.sh [root] [path ...]
# Default scan: PUG_RG_SRC or . Escape hatch: pug-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.pug / *.jade.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for pug-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${PUG_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${PUG_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
# Note: docs name != "unescaped buffered"; user/brief shorthand "unbuffered = XSS".
IDS=(unescaped_buffered_xss include_untrusted_path mixin_injection)
SCAN_PATS=(
  '(?m)(?:\w|^\s*)!=(?!=)|!\{'
  '(?i)^\s*include\s+(#\{|!\{)'
  '(?i)\+#\{|\+!\{'
)
CLASS_PATS=(
  '(?:\w|:[0-9]+:.*)!=(?!=)|!\{'
  '(?i):[0-9]+:[[:space:]]*include\s+(#\{|!\{)'
  '(?i)\+#\{|\+!\{'
)

MSGS=(
  'unescaped buffered XSS banned (!= / !{}; prefer buffered = / #{}; pug-rg-allow with rationale)'
  'include of untrusted interpolated path banned (include #{…} / include !{…}; prefer static trusted paths; pug-rg-allow with rationale)'
  'mixin injection banned (dynamic mixin name +#{…} / +!{…}; prefer static +name; pug-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.pug' --glob '*.Pug' --glob '*.jade' --glob '*.Jade'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and Pug comment-only hits (line is only a //- comment).
  rg -v 'pug-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//-)' >"$FILT" || true
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
echo "PASS pug-rg-gate (${TARGETS[*]}, single-walk)"
