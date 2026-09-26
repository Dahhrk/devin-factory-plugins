#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Delphi / Object Pascal smells (portable regex bar).
# PSR: no goto; no with-statement; unchecked GetMem; WriteLn banned in library units.
# Language-farm. Product FPC / Delphi checkers remain authoritative for depth;
# this gate is the portable rg bar for Pascal trust smells.
#
# Usage: bash scripts/delphi-rg-gate.sh [root] [path ...]
# Default scan: DELPHI_RG_SRC or . Escape hatch: delphi-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for delphi-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${DELPHI_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${DELPHI_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(goto with_stmt unchecked_getmem writeln_lib)
SCAN_PATS=(
  '(?i)\bgoto\b'
  '(?i)\bwith\b[[:space:]]+[^\n;{]+[[:space:]]+do\b'
  '(?i)\b(?:System\.)?GetMem\s*\('
  '(?i)(?<!\.)\bwriteln\b'
)
CLASS_PATS=(
  '(?i)\bgoto\b'
  '(?i)\bwith\b[[:space:]]+[^\n;{]+[[:space:]]+do\b'
  '(?i)\b(?:System\.)?GetMem\s*\('
  '(?i)(?<!\.)\bwriteln\b'
)
MSGS=(
  'goto banned (prefer structured loops / Exit / raise; delphi-rg-allow with rationale)'
  'with-statement banned (prefer explicit qualifiers; delphi-rg-allow with rationale)'
  'Unchecked GetMem banned (prefer New / managed types; GetMem is the unchecked heap API; delphi-rg-allow with rationale)'
  'WriteLn in library units banned (prefer logging / Result; CLI programs .dpr/.lpr may WriteLn; delphi-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

# Library units only for WriteLn; goto/with/GetMem scan same globs.
# .dpr/.lpr are programs (WriteLn OK there) — exclude from writeln classify via path.
rg_globs=(
  --glob '*.pas' --glob '*.pp' --glob '*.inc'
  --glob '*.PAS' --glob '*.PP' --glob '*.INC'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**'
  --glob '!**/target/**' --glob '!**/testdata/**'
  --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/test/**'
  --glob '!**/samples/**' --glob '!**/Samples/**' --glob '!**/examples/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and Pascal comment-only hits (// and { } line-leading comments).
  rg -v 'delphi-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*//' \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*\{' >"$FILT" || true
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

  # GetMem is the unchecked heap API (prefer New / managed types; allow with rationale).
  # WriteLn classify already limited to .pas/.pp globs (programs use .dpr/.lpr).

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
echo "PASS delphi-rg-gate (${TARGETS[*]}, single-walk)"
