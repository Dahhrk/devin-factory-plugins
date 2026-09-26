#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Zig smells (portable regex bar).
# PSR: zig fmt + zig build test; no @panic/@trap in libs; no catch unreachable
# (unchecked alloc and other ignored errors); no TODO/FIXME. Language-farm.
# Product zig fmt / zig build test remain authoritative for depth; this gate is
# the portable rg bar for Zig trust smells.
#
# Usage: bash scripts/zig-rg-gate.sh [root] [path ...]
# Default scan: ZIG_RG_SRC or . Escape hatch: zig-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg). Comment TODOs are in scope (do not strip // lines).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for zig-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${ZIG_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${ZIG_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(panic_trap unchecked_alloc todo)
SCAN_PATS=(
  '@panic\b|@trap\b'
  'catch[[:space:]]+unreachable'
  '\bTODO\b|\bFIXME\b'
)
CLASS_PATS=(
  '@panic\b|@trap\b'
  'catch[[:space:]]+unreachable'
  '\bTODO\b|\bFIXME\b'
)
MSGS=(
  '@panic/@trap banned in libs (prefer error union / return error.; zig-rg-allow with rationale)'
  'catch unreachable banned (unchecked alloc and ignored errors; prefer try/errdefer; zig-rg-allow with rationale)'
  'TODO/FIXME banned in product paths (finish or track outside; zig-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.zig' --glob '!**/.git/**' --glob '!**/zig-cache/**' --glob '!**/zig-out/**' --glob '!**/tmp/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/Test/**' --glob '!**/Tests/**' --glob '!**/examples/**' --glob '!**/fixtures/**' --glob '!**/docs/**' --glob '!**/tools/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows only. Keep // TODO comments in scope for the todo smell.
  rg -v 'zig-rg-allow' "$ALL" >"$FILT" || true
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
echo "PASS zig-rg-gate (${TARGETS[*]}, single-walk)"
