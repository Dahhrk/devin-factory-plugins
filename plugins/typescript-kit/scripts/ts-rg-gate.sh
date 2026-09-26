#!/usr/bin/env bash
# Tier 0: Programming Standards Reference TypeScript smells (any/assertions,
# DOM non-null, bare JSON.parse, double assertion, bare @ts-expect-error).
# Product oxlint/tsc remain authoritative for typed depth; this gate is the
# portable regex bar.
#
# Usage: bash scripts/ts-rg-gate.sh [root]
# Default scan dir: src (override with TS_RG_SRC). When src is missing, tries
# lib then app before failing.
# Escape hatch: ts-rg-allow on the line.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

pick_src() {
  if [[ -n "${TS_RG_SRC:-}" ]]; then
    echo "$TS_RG_SRC"
    return
  fi
  for candidate in src lib app; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

SRC="$(pick_src)"
if [[ -z "$SRC" ]]; then
  echo "FAIL: expected source dir src (or lib/app); set TS_RG_SRC to override (root=$ROOT)"
  exit 1
fi
if [[ ! -d "$SRC" ]]; then
  echo "FAIL: source dir '$SRC' missing under $ROOT (set TS_RG_SRC to override)"
  exit 1
fi

fail=0
HITFILE="$(mktemp)"
trap 'rm -f "$HITFILE" "$HITFILE.f"' EXIT

check() {
  local pat="$1" msg="$2"
  : >"$HITFILE"
  if command -v rg >/dev/null 2>&1; then
    rg -n --glob '*.ts' --glob '*.tsx' --glob '*.mts' --glob '*.cts' \
      --glob '!**/node_modules/**' --glob '!**/.git/**' \
      -e "$pat" "$SRC" >"$HITFILE" 2>/dev/null || true
  else
    find "$SRC" \( -name '*.ts' -o -name '*.tsx' -o -name '*.mts' -o -name '*.cts' \) \
      ! -path '*/node_modules/*' ! -path '*/.git/*' -print0 2>/dev/null \
      | xargs -0 grep -nE "$pat" >"$HITFILE" 2>/dev/null || true
  fi
  if [[ ! -s "$HITFILE" ]]; then
    return 0
  fi
  if command -v rg >/dev/null 2>&1; then
    rg -v 'ts-rg-allow' "$HITFILE" >"$HITFILE.f" || true
  else
    grep -v 'ts-rg-allow' "$HITFILE" >"$HITFILE.f" || true
  fi
  if [[ -s "$HITFILE.f" ]]; then
    echo "FAIL: $msg"
    head -40 "$HITFILE.f"
    local n
    n=$(wc -l <"$HITFILE.f" | tr -d ' ')
    if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
    fail=1
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

# Double assertion slips past as-any ban (tRPC / product residual -> encode)
check '\bas\s+unknown\s+as\b' 'as unknown as banned (prefer named parse / satisfies; ts-rg-allow with rationale)'

# Bare expect-error without rationale
check '@ts-expect-error(?!\s+\S)' '@ts-expect-error requires a trailing description (e.g. // @ts-expect-error - reason)'

# PSR: avoid unexplained assertions on external/DOM data
check 'getElementById\s*\([^)]*\)\s*!' 'DOM non-null: getElementById(...)! banned; check null then use narrowed node'
check 'querySelector(All)?\s*\([^)]*\)\s*!' 'DOM non-null: querySelector*(...)! banned; check null then use narrowed node'

# PSR: validate external data at runtime (bare parse is a boundary smell)
check '\bJSON\.parse\s*\(' 'JSON.parse in src banned without a typed parse boundary (move behind a named parser or schema; ts-rg-allow on the parser line if needed)'

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-rg-gate ($ROOT/$SRC)"
