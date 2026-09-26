#!/usr/bin/env bash
# Tier 0: Programming Standards Reference C smells (portable regex bar).
# PSR: strong diagnostics; bounds/lifetime; sanitizers; explicit UB handling.
# Practical encode (language-farm): unsafe string APIs (strcpy/strcat/sprintf/gets).
# Product clang-format / -Wall -Wextra / sanitizers remain authoritative for depth;
# this gate is the portable rg bar for buffer/unsafe string smells.
#
# Usage: bash scripts/c-rg-gate.sh [root] [path ...]
# Default scan: C_RG_SRC or . Escape hatch: c-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for c-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${C_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${C_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# SCAN_PATS match source lines. CLASS_PATS match rg "path:line:code" output.
IDS=(strcpy strcat sprintf gets)
SCAN_PATS=(
  '\bstrcpy[[:space:]]*\('
  '\bstrcat[[:space:]]*\('
  '\bsprintf[[:space:]]*\('
  '\bgets[[:space:]]*\('
)
CLASS_PATS=(
  '\bstrcpy[[:space:]]*\('
  '\bstrcat[[:space:]]*\('
  '\bsprintf[[:space:]]*\('
  '\bgets[[:space:]]*\('
)
MSGS=(
  'strcpy banned (prefer snprintf/strlcpy/bounded copy; c-rg-allow with rationale)'
  'strcat banned (prefer snprintf/strlcat/bounded append; c-rg-allow with rationale)'
  'sprintf banned (prefer snprintf; c-rg-allow with rationale)'
  'gets banned (prefer fgets with bound; c-rg-allow never for prod)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.c' --glob '*.h' --glob '!**/build/**' --glob '!**/cmake-build*/**' --glob '!**/.git/**' --glob '!**/out/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'c-rg-allow' "$ALL" >"$FILT" || true
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
  rg -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
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
echo "PASS c-rg-gate (${TARGETS[*]}, single-walk)"
