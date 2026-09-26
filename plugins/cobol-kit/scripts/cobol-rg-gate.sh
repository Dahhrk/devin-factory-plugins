#!/usr/bin/env bash
# Tier 0: Programming Standards Reference COBOL smells (portable regex bar).
# PSR: no GOTO/ALTER; checked ACCEPT (ON EXCEPTION); END-IF hygiene.
# Language-farm. Product cobc / enterprise checkers remain authoritative for
# depth; this gate is the portable rg bar for COBOL trust smells.
#
# Usage: bash scripts/cobol-rg-gate.sh [root] [path ...]
# Default scan: COBOL_RG_SRC or . Escape hatch: cobol-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel;
# cheap second pass for IF/END-IF imbalance.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for cobol-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${COBOL_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${COBOL_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(goto alter unchecked_accept)
SCAN_PATS=(
  '(?i)\bgo\s*to\b'
  '(?i)\bALTER\b'
  '(?i)^[[:space:]]*ACCEPT\b'
)
CLASS_PATS=(
  '(?i)\bgo\s*to\b'
  '(?i)\bALTER\b'
  '(?i):[0-9]+:[[:space:]]*ACCEPT\b'
)
MSGS=(
  'GOTO / GO TO banned (prefer PERFORM / EVALUATE / structured EXIT; cobol-rg-allow with rationale)'
  'ALTER banned (prefer explicit PERFORM targets; cobol-rg-allow with rationale)'
  'Unchecked ACCEPT banned (ACCEPT needs ON EXCEPTION or ON ERROR on the same line; cobol-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.cob' --glob '*.cbl' --glob '*.cpy'
  --glob '*.COB' --glob '*.CBL' --glob '*.CPY'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**'
  --glob '!**/target/**' --glob '!**/testdata/**'
  --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/test/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and COBOL comment-only hits (* > free-form, * fixed indicator).
  rg -v 'cobol-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*\*>' \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*\*' >"$FILT" || true
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

  # Unchecked ACCEPT: keep ACCEPT lines lacking ON EXCEPTION / ON ERROR
  if [[ "$id" == "unchecked_accept" && -s "$hitfile" ]]; then
    rg -vi 'ON[[:space:]]+(EXCEPTION|ERROR)\b' "$hitfile" >"$TMPDIR_GATE/hit.$id.acc" 2>/dev/null || true
    mv "$TMPDIR_GATE/hit.$id.acc" "$hitfile"
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

# File-level END-IF hygiene: IF verb count must not exceed END-IF count.
# Period-terminated IF-without-END-IF and nested imbalance both trip this.
# Fast path: two tree-wide rg -n passes, aggregate per file (exclude ELSE IF / comments).
IMBAL="$TMPDIR_GATE/endif_imbalance"
: >"$IMBAL"
IF_HITS="$TMPDIR_GATE/if_hits"
ENDIF_HITS="$TMPDIR_GATE/endif_hits"
rg -n -i -P "${rg_globs[@]}" '(?i)(?<!ELSE )(?<!END-)\bIF\b' "${TARGETS[@]}" >"$IF_HITS" 2>/dev/null || true
rg -n -i -P "${rg_globs[@]}" '(?i)\bEND-IF\b' "${TARGETS[@]}" >"$ENDIF_HITS" 2>/dev/null || true

# Drop comment-only hits and allow markers from IF hits.
if [[ -s "$IF_HITS" ]]; then
  rg -v 'cobol-rg-allow' "$IF_HITS" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*\*>' \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*\*' >"$TMPDIR_GATE/if_filt" || true
else
  : >"$TMPDIR_GATE/if_filt"
fi
if [[ -s "$ENDIF_HITS" ]]; then
  rg -v '^[^\n]*:[0-9]+:[[:space:]]*\*>' "$ENDIF_HITS" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*\*' >"$TMPDIR_GATE/endif_filt" || true
else
  : >"$TMPDIR_GATE/endif_filt"
fi

# Aggregate counts: path is everything before the last two colon-separated fields (line, text)
# Use awk: split on first :line: occurrence via match.
awk '
function key(line,   a, n) {
  # file may contain colons rarely; COBOL paths here are simple
  n = split(line, a, ":")
  if (n < 3) return ""
  return a[1]
}
FNR==NR {
  k = key($0)
  if (k != "") ifc[k]++
  next
}
{
  k = key($0)
  if (k != "") eifc[k]++
}
END {
  for (k in ifc) {
    e = (k in eifc) ? eifc[k] : 0
    if (ifc[k] > e) printf "%s  IF=%d END-IF=%d\n", k, ifc[k], e
  }
}
' "$TMPDIR_GATE/if_filt" "$TMPDIR_GATE/endif_filt" >"$IMBAL" || true

if [[ -s "$IMBAL" ]]; then
  report_fail "IF/END-IF imbalance (IF count exceeds END-IF; prefer END-IF for every IF; period-terminated IF-without-END-IF is a smell; ELSE IF shares the outer END-IF)" "$IMBAL"
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS cobol-rg-gate (${TARGETS[*]}, single-walk)"
