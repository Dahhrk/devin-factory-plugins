#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Vite smells (portable regex bar).
# PSR: vite wiring; no server.fs.strict:false; no parent-escape server.fs.allow;
# no loadEnv(..., '') empty-prefix all-env dump.
# Language-farm. Product Vite remains authoritative for build/dev; this gate
# is the portable rg bar for Vite trust smells.
#
# Usage: bash scripts/vite-rg-gate.sh [root] [path ...]
# Default scan: VITE_RG_SRC or . Escape hatch: vite-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers vite.config.* and related JS/TS.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for vite-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${VITE_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${VITE_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

IDS=(fs_strict_false fs_allow_parent loadenv_empty_prefix)
SCAN_PATS=(
  '(?i)\bstrict\s*:\s*false\b'
  '(?i)\ballow\s*:\s*\[[^\]]*(['\''\"])\.\.\1'
  '(?i)\bloadEnv\s*\([^)]*,[^)]*,\s*['\''\"]['\''\"]'
)
CLASS_PATS=(
  '(?i)\bstrict\s*:\s*false\b'
  '(?i)\ballow\s*:\s*\[[^\]]*(['\''\"])\.\.\1'
  '(?i)\bloadEnv\s*\([^)]*,[^)]*,\s*['\''\"]['\''\"]'
)
MSGS=(
  'server.fs.strict:false banned (keep default strict:true; vite-rg-allow with rationale)'
  'server.fs.allow parent escape (allow: [''..'']) banned (prefer workspace root / explicit dirs; vite-rg-allow with rationale)'
  'loadEnv empty-prefix (loadEnv(mode, dir, '''')) banned (prefer VITE_ prefix filter; empty third arg loads all env; vite-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob 'vite.config.*' --glob 'vitest.config.*' --glob '*.config.js' --glob '*.config.ts' --glob '*.config.mjs' --glob '*.config.cjs' --glob '*.config.mts' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**' --glob '!**/playground/**' --glob '!**/docs/**' --glob '!**/__tests__/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'vite-rg-allow' "$ALL" 2>/dev/null \
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
  # Narrow strict:false to fs/server context when possible: keep all — product configs using strict:false elsewhere rare; still bar
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
echo "PASS vite-rg-gate (${TARGETS[*]}, single-walk)"
