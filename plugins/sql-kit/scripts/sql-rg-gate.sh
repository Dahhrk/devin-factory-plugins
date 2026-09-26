#!/usr/bin/env bash
# Tier 0: Programming Standards Reference SQL smells (portable regex bar).
# PSR: sqlfluff lint; no SELECT *; no SQL injection concat; no unsafe dynamic SQL.
# Language-farm. Product sqlfluff remains authoritative for depth; this gate is
# the portable rg bar for SQL trust smells.
#
# Usage: bash scripts/sql-rg-gate.sh [root] [path ...]
# Default scan: SQL_RG_SRC or . Escape hatch: sql-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for sql-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${SQL_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${SQL_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(select_star sql_concat unsafe_dynamic)
SCAN_PATS=(
  '(?i)\bSELECT[[:space:]]+(\*|[[:alnum:]_."`\[\]]+\.\*)'
  '(?i)(["'"'"'](SELECT|INSERT|UPDATE|DELETE|WITH)[[:space:]][^"'"'"']*["'"'"'][[:space:]]*\+)|(\+[[:space:]]*["'"'"'](SELECT|INSERT|UPDATE|DELETE|[[:space:]]+(WHERE|FROM|AND|OR|VALUES|SET))[^"'"'"']*["'"'"'])|(f["'"'"'](SELECT|INSERT|UPDATE|DELETE|WITH)\b)|((?i)@(sql|query|stmt|command)[[:space:]]*=[[:space:]]*[^;]*\+)|((?i)["'"'"'][^"'"'"']*["'"'"'][[:space:]]*\+[[:space:]]*@)'
  '(?i)\bEXECUTE[[:space:]]+IMMEDIATE\b|\bEXEC[[:space:]]*\([[:space:]]*@|\bsp_executesql[[:space:]]*\([^)]*\+|\bPREPARE[[:space:]]+[[:alnum:]_]+[[:space:]]+FROM[[:space:]]+@'
)
CLASS_PATS=(
  '(?i)\bSELECT[[:space:]]+(\*|[[:alnum:]_."`\[\]]+\.\*)'
  '(?i)(["'"'"'](SELECT|INSERT|UPDATE|DELETE|WITH)[[:space:]][^"'"'"']*["'"'"'][[:space:]]*\+)|(\+[[:space:]]*["'"'"'](SELECT|INSERT|UPDATE|DELETE|[[:space:]]+(WHERE|FROM|AND|OR|VALUES|SET))[^"'"'"']*["'"'"'])|(f["'"'"'](SELECT|INSERT|UPDATE|DELETE|WITH)\b)|((?i)@(sql|query|stmt|command)[[:space:]]*=[[:space:]]*[^;]*\+)|((?i)["'"'"'][^"'"'"']*["'"'"'][[:space:]]*\+[[:space:]]*@)'
  '(?i)\bEXECUTE[[:space:]]+IMMEDIATE\b|\bEXEC[[:space:]]*\([[:space:]]*@|\bsp_executesql[[:space:]]*\([^)]*\+|\bPREPARE[[:space:]]+[[:alnum:]_]+[[:space:]]+FROM[[:space:]]+@'
)
MSGS=(
  'SELECT * / table.* banned (prefer explicit columns; sql-rg-allow with rationale; sqlfluff AM04)'
  'SQL string concat / injection smell banned (prefer bound parameters / prepared statements; sql-rg-allow with rationale)'
  'Unsafe dynamic SQL banned (EXECUTE IMMEDIATE / EXEC(@…) / sp_executesql+concat / PREPARE FROM @; prefer parameterized; sql-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.sql' --glob '*.SQL' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and SQL-comment-only hits (leading -- after line num).
  rg -v 'sql-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*--' >"$FILT" || true
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
echo "PASS sql-rg-gate (${TARGETS[*]}, single-walk)"
