#!/usr/bin/env bash
# Tier 1b: malloc/calloc/realloc must be NULL-checked nearby (PSR: lifetime/ownership).
# For each assignment from malloc|calloc|realloc, require a NULL / !ptr check
# within the next C_MALLOC_WINDOW lines (default 4). Escape: c-rg-allow on the
# allocation line (shared with rg-gate allow marker).
# Usage: bash scripts/c-malloc-gate.sh [root] [path ...]
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for c-malloc-gate"
  exit 1
fi

WINDOW="${C_MALLOC_WINDOW:-4}"
if ! [[ "$WINDOW" =~ ^[0-9]+$ ]] || [[ "$WINDOW" -lt 1 ]]; then
  echo "FAIL: C_MALLOC_WINDOW must be a positive integer"
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

TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
HITS="$TMPDIR_GATE/hits"
: >"$HITS"

rg -n --glob '*.c' --glob '*.h' --glob '!**/build/**' --glob '!**/.git/**' \
  '[=][[:space:]]*(malloc|calloc|realloc)[[:space:]]*\(' "${TARGETS[@]}" >"$HITS" 2>/dev/null || true

fail=0
BAD="$TMPDIR_GATE/bad"
: >"$BAD"

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" ]] && continue
  # path:lineno:code
  path="${line%%:*}"
  rest="${line#*:}"
  lineno="${rest%%:*}"
  code="${rest#*:}"
  if echo "$code" | rg -q 'c-rg-allow'; then
    continue
  fi
  # Extract LHS identifier if present:  ptr = malloc(
  var=""
  if echo "$code" | rg -q '[[:alpha:]_][[:alnum:]_]*[[:space:]]*='; then
    var=$(echo "$code" | sed -n 's/.*[^[:alnum:]_]\([[:alpha:]_][[:alnum:]_]*\)[[:space:]]*=.*/\1/p')
    if [[ -z "$var" ]]; then
      var=$(echo "$code" | sed -n 's/^[[:space:]]*\([[:alpha:]_][[:alnum:]_]*\)[[:space:]]*=.*/\1/p')
    fi
  fi
  start=$((lineno + 1))
  end=$((lineno + WINDOW))
  window_txt=$(sed -n "${start},${end}p" "$path" 2>/dev/null || true)
  ok=0
  if echo "$window_txt" | rg -q 'NULL'; then
    ok=1
  fi
  if [[ -n "$var" ]] && echo "$window_txt" | rg -q "!\s*$var\b|if\s*\(\s*!\s*$var\b"; then
    ok=1
  fi
  if [[ "$ok" -eq 0 ]]; then
    echo "$line" >>"$BAD"
  fi
done <"$HITS"

if [[ -s "$BAD" ]]; then
  echo "FAIL: malloc/calloc/realloc without nearby NULL check (window=${WINDOW}; add check or c-rg-allow)"
  head -40 "$BAD"
  n=$(wc -l <"$BAD" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS c-malloc-gate (${TARGETS[*]}, window=${WINDOW})"
