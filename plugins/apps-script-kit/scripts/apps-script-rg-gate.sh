#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Apps Script smells (portable regex bar).
# PSR: eval/new Function banned; Logger.log in libs banned; SpreadsheetApp.getUi
#      (and DocumentApp/FormApp/SlidesApp siblings) in doGet/doPost files banned;
#      concurrent sheet writes (doPost/onFormSubmit + setValue(s)/appendRow)
#      without LockService banned when gateable.
# Language-farm. Product clasp / Apps Script tests remain authoritative for depth;
# this gate is the portable rg bar for Apps Script trust smells.
#
# Usage: bash scripts/apps-script-rg-gate.sh [root] [path ...]
# Default scan: APPS_SCRIPT_RG_SRC or . Escape hatch: apps-script-rg-allow on the line
#   (or file-level for lock/getUi file smells: apps-script-rg-allow anywhere in file).
# Hot-path: one tree walk (union of line smells), classify hit set in parallel,
# then file-level getUi/lock checks.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for apps-script-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${APPS_SCRIPT_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${APPS_SCRIPT_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(eval_call logger_log getui)
SCAN_PATS=(
  '(?i)\beval\s*\(|\bnew\s+Function\s*\('
  '(?i)\bLogger\.log\s*\('
  '(?i)\b(SpreadsheetApp|DocumentApp|FormApp|SlidesApp)\.getUi\s*\('
)
CLASS_PATS=(
  '(?i)\beval\s*\(|\bnew\s+Function\s*\('
  '(?i)\bLogger\.log\s*\('
  '(?i)\b(SpreadsheetApp|DocumentApp|FormApp|SlidesApp)\.getUi\s*\('
)
MSGS=(
  'eval / new Function banned (prefer parsers + typed data; apps-script-rg-allow with rationale)'
  'Logger.log in libs banned (prefer return values; temporary probes must not ship; apps-script-rg-allow with rationale)'
  'getUi in doGet/doPost file banned (web-app wrong context; use HtmlService or container onOpen; apps-script-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.gs' --glob '*.js' --glob '*.mjs' --glob '*.cjs'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/coverage/**'
  --glob '!**/testdata/**'
  --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/test/**'
  --glob '!**/samples/**' --glob '!**/Samples/**' --glob '!**/examples/**'
  --glob '!**/example/**' --glob '!**/*.test.js' --glob '!**/*.spec.js'
  --glob '!**/docs/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading // or /* or * after line num).
  rg -v 'apps-script-rg-allow' "$ALL" 2>/dev/null \
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

  # getui: only fail when the same source file also defines doGet/doPost.
  if [[ "$id" == "getui" && -s "$hitfile" ]]; then
    : >"$TMPDIR_GATE/hit.$id.wrong"
    declare -A seen_files=()
    while IFS= read -r line || [[ -n "$line" ]]; do
      f="${line%%:*}"
      [[ -z "$f" ]] && continue
      if [[ -z "${seen_files[$f]+x}" ]]; then
        seen_files[$f]=0
        if [[ -f "$f" ]] && rg -q -P '(?i)\bfunction\s+do(Get|Post)\s*\(|\bexports\.do(Get|Post)\s*=' "$f" 2>/dev/null; then
          # File-level allow: apps-script-rg-allow anywhere in file
          if rg -q 'apps-script-rg-allow' "$f" 2>/dev/null; then
            seen_files[$f]=0
          else
            seen_files[$f]=1
          fi
        fi
      fi
      if [[ "${seen_files[$f]}" == "1" ]]; then
        echo "$line" >>"$TMPDIR_GATE/hit.$id.wrong"
      fi
    done <"$hitfile"
    mv "$TMPDIR_GATE/hit.$id.wrong" "$hitfile"
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

# File-level: concurrent write without LockService (gateable).
# doPost / onFormSubmit + appendRow|setValues|setValue and no LockService.
LOCK_HIT="$TMPDIR_GATE/hit.missing_lock"
: >"$LOCK_HIT"
mapfile -t gas_files < <(rg -l -P --glob '*.gs' --glob '*.js' --glob '*.mjs' --glob '*.cjs' \
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' \
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/testdata/**' \
  --glob '!**/tests/**' --glob '!**/test/**' --glob '!**/samples/**' \
  --glob '!**/examples/**' --glob '!**/docs/**' \
  '(?i)\bfunction\s+(doPost|onFormSubmit)\s*\(|\bexports\.(doPost|onFormSubmit)\s*=' \
  "${TARGETS[@]}" 2>/dev/null || true)
for f in "${gas_files[@]:-}"; do
  [[ -z "$f" || ! -f "$f" ]] && continue
  if rg -q 'apps-script-rg-allow' "$f" 2>/dev/null; then
    continue
  fi
  if rg -q -P '(?i)\.(appendRow|setValues|setValue)\s*\(' "$f" 2>/dev/null; then
    if ! rg -q -P '(?i)\bLockService\b' "$f" 2>/dev/null; then
      echo "$f: missing LockService for concurrent write (doPost/onFormSubmit + setValue(s)/appendRow)" >>"$LOCK_HIT"
    fi
  fi
done
if [[ -s "$LOCK_HIT" ]]; then
  report_fail 'concurrent sheet write without LockService banned (doPost/onFormSubmit + appendRow/setValues/setValue; wrap with LockService; apps-script-rg-allow with rationale)' "$LOCK_HIT"
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS apps-script-rg-gate (${TARGETS[*]}, single-walk)"
