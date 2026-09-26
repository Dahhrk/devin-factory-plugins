#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Ada smells (portable regex bar).
# PSR: no Unchecked_Conversion; no pragma Suppress; gnatcheck/gnatpp wiring (Tier 1).
# Language-farm. Product gnatcheck remains authoritative for depth; this
# gate is the portable rg bar for Ada trust smells.
#
# Usage: bash scripts/ada-rg-gate.sh [root] [path ...]
# Default scan: ADA_RG_SRC or . Escape hatch: ada-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for ada-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${ADA_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${ADA_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(unchecked_conversion pragma_suppress)
SCAN_PATS=(
  '(?i)\bAda\.Unchecked_Conversion\b|\bUnchecked_Conversion\b'
  '(?i)^\s*pragma\s+Suppress\b'
)
CLASS_PATS=(
  '(?i)\bAda\.Unchecked_Conversion\b|\bUnchecked_Conversion\b'
  '(?i):[0-9]+:[[:space:]]*pragma\s+Suppress\b'
)
MSGS=(
  'Unchecked_Conversion banned (prefer typed conversions / Streams / representation clauses; ada-rg-allow with rationale)'
  'pragma Suppress banned (prefer keeping checks; handle Constraint_Error; ada-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.ads' --glob '*.adb' --glob '*.ada' --glob '*.Ada'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**'
  --glob '!**/obj/**' --glob '!**/target/**' --glob '!**/testdata/**'
  --glob '!**/alire/**' --glob '!**/.alire/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and Ada comment-only lines (-- ...).
  rg -v 'ada-rg-allow' "$ALL" 2>/dev/null \
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

  # Drop Unchecked_Conversion hits that are only end-of-line comments after code-free `--`
  # (already filtered comment-only lines). Also drop `---Unchecked_Conversions` gnatcheck
  # rules file lines if they ever leak in (rules are not .ad[bs]).
  if [[ "$id" == "unchecked_conversion" && -s "$hitfile" ]]; then
    # Keep with/use/instantiation forms; drop pure identifier mentions inside strings rare.
    rg -P '(?i)(with|use|new|function|procedure|package|is)?[[:space:]]*.*\bUnchecked_Conversion\b|\bAda\.Unchecked_Conversion\b' \
      "$hitfile" >"$TMPDIR_GATE/hit.$id.keep" 2>/dev/null || true
    # Prefer keeping all remaining FILT hits for UC — they are already non-comment.
    if [[ ! -s "$TMPDIR_GATE/hit.$id.keep" ]]; then
      cp "$hitfile" "$TMPDIR_GATE/hit.$id.keep"
    fi
    mv "$TMPDIR_GATE/hit.$id.keep" "$hitfile"
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

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS ada-rg-gate (${TARGETS[*]}, single-walk)"
