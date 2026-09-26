#!/usr/bin/env bash
# Tier 0: Programming Standards Reference TypeScript smells (any/assertions,
# DOM non-null, bare JSON.parse). Product oxlint/tsc remain authoritative for
# typed depth; this gate is the portable regex bar.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
SRC="${TS_RG_SRC:-src}"
if [[ ! -d "$SRC" ]]; then
  echo "FAIL: expected source dir '$SRC' under $ROOT (set TS_RG_SRC to override)"
  exit 1
fi
fail=0
HITFILE="$(mktemp)"
trap 'rm -f "$HITFILE"' EXIT

check() {
  local pat="$1" msg="$2"
  : >"$HITFILE"
  local hits=0
  if command -v rg >/dev/null 2>&1; then
    if rg -n --glob '*.ts' --glob '*.tsx' -e "$pat" "$SRC" >"$HITFILE" 2>/dev/null; then
      hits=1
    fi
  else
    if grep -RIn --include='*.ts' --include='*.tsx' -E "$pat" "$SRC" >"$HITFILE" 2>/dev/null; then
      hits=1
    fi
  fi
  if [[ "$hits" -eq 1 ]]; then
    # Drop intentional escape-hatch lines
    if command -v rg >/dev/null 2>&1; then
      if rg -v 'ts-rg-allow' "$HITFILE" >"${HITFILE}.f" 2>/dev/null && [[ -s "${HITFILE}.f" ]]; then
        echo "FAIL: $msg"
        cat "${HITFILE}.f"
        fail=1
      fi
      rm -f "${HITFILE}.f"
    else
      if grep -v 'ts-rg-allow' "$HITFILE" >"${HITFILE}.f" 2>/dev/null && [[ -s "${HITFILE}.f" ]]; then
        echo "FAIL: $msg"
        cat "${HITFILE}.f"
        fail=1
      fi
      rm -f "${HITFILE}.f"
    fi
  fi
}

# PSR: avoid unexplained any (type positions only; not English "any" in comments)
check '\bas\s+any\b' 'as any banned'
check ':\s*any\b' 'explicit : any banned'
check '<any>' 'generic any banned'
check '\bany\[' 'any[] banned'
check '\bPromise\s*<\s*any\s*>' 'Promise<any> banned'
check '\bRecord\s*<\s*[^,]+,\s*any\s*>' 'Record<*, any> banned'
check '@ts-ignore\b' '@ts-ignore banned (prefer typed fix or @ts-expect-error with description via oxlint)'
check '@ts-nocheck\b' '@ts-nocheck banned'

# PSR: avoid unexplained assertions on external/DOM data
check 'getElementById\s*\([^)]*\)\s*!' 'DOM non-null: getElementById(...)! banned; check null then use narrowed node'
check 'querySelector(All)?\s*\([^)]*\)\s*!' 'DOM non-null: querySelector*(...)! banned; check null then use narrowed node'

# PSR: validate external data at runtime (bare parse is a boundary smell)
check '\bJSON\.parse\s*\(' 'JSON.parse in src banned without a typed parse boundary (move behind a named parser or schema; ts-rg-allow on the parser line if needed)'

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-rg-gate ($ROOT/$SRC)"
