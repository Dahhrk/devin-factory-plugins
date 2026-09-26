#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Mako smells (portable regex bar).
# PSR: no disable_unicode / input_encoding footguns; no untrusted <%include>;
# no ${} without filters / |n raw; no module_directory code-exec cache paths.
# Language-farm. Product Mako/Python toolchain remains authoritative for render;
# this gate is the portable rg bar for Mako trust smells.
#
# Usage: bash scripts/mako-rg-gate.sh [root] [path ...]
# Default scan: MAKO_RG_SRC or . Escape hatch: mako-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.mako / *.html / *.py / *.pyi.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for mako-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${MAKO_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${MAKO_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
IDS=(disable_unicode_encoding untrusted_include raw_unfiltered_expr module_directory_cache)
SCAN_PATS=(
  '(?i)disable_unicode\s*=|input_encoding\s*=\s*(?:None|["'\'']None["'\'']|["'\'']latin-?1["'\'']|["'\'']ascii["'\''])'
  '<%include\b[^>]*\$\{'
  '(?i)(\|\s*n\b|expression_filter\s*=\s*["'\'']n["'\'']|default_filters\s*=\s*\[\s*\])'
  'module_directory\s*='
)
CLASS_PATS=(
  '(?i)disable_unicode\s*=|input_encoding\s*=\s*(?:None|["'\'']None["'\'']|["'\'']latin-?1["'\'']|["'\'']ascii["'\''])'
  '<%include\b[^>]*\$\{'
  '(?i)(\|\s*n\b|expression_filter\s*=\s*["'\'']n["'\'']|default_filters\s*=\s*\[\s*\])'
  'module_directory\s*='
)

MSGS=(
  'disable_unicode / input_encoding footgun banned (disable_unicode= / input_encoding None|latin-1|ascii; prefer utf-8 + Py3 str; mako-rg-allow with rationale)'
  'untrusted <%include> banned (<%include file=...${...}; prefer static include path; mako-rg-allow with rationale)'
  '${} without filters / |n raw banned (|n / expression_filter="n" / default_filters=[]; prefer |h or <%page expression_filter="h"/>; mako-rg-allow with rationale)'
  'module_directory code-exec cache path banned (module_directory= writes executable .py; prefer no module_directory or locked path + allow; mako-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.mako' --glob '*.Mako' --glob '*.html' --glob '*.HTML'
  --glob '*.py' --glob '*.pyi'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**' --glob '!**/__pycache__/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and Python/hash/line-comment-only hits (## Mako comments + # py + //).
  rg -v 'mako-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(#|//|/\*|\*|##)' >"$FILT" || true
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
echo "PASS mako-rg-gate (${TARGETS[*]}, single-walk)"
