#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Wasm smells (portable regex bar).
# PSR: wat hygiene (leftover debug call/import) banned; unbounded memory.grow
#      without same-line ;; comment banned; imported host eval patterns banned.
# Language-farm. Product wat2wasm / wasm-tools remain authoritative for depth;
# this gate is the portable rg bar for Wasm trust smells.
#
# Usage: bash scripts/wasm-rg-gate.sh [root] [path ...]
# Default scan: WASM_RG_SRC or . Escape hatch: wasm-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for wasm-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${WASM_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${WASM_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(wat_debug memory_grow host_eval)
SCAN_PATS=(
  '(?i)(\(call\s+\$(print|log|debug)\b|\(import\s+"console"\s+"log")'
  '(?i)\bmemory\.grow\b'
  '(?i)\(import\s+"[^"]*"\s+"(eval|eval_js|Function|exec|js_eval)"'
)
# Fix: space in $ (print was wrong - need \$print without space
CLASS_PATS=(
  '(?i)(\(call\s+\$(print|log|debug)\b|\(import\s+"console"\s+"log")'
  '(?i)\bmemory\.grow\b'
  '(?i)\(import\s+"[^"]*"\s+"(eval|eval_js|Function|exec|js_eval)"'
)
MSGS=(
  'wat hygiene: leftover call $print/$log/$debug or (import "console" "log" banned (prefer remove before merge; wasm-rg-allow with rationale)'
  'memory.grow without same-line ;; bound comment banned (document pages/limit; wasm-rg-allow with rationale)'
  'imported host eval pattern banned (eval/eval_js/Function/exec/js_eval; prefer typed host API; wasm-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.wat' --glob '*.wast' --glob '*.WAT' --glob '*.WAST'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/target/**' --glob '!**/build/**' --glob '!**/dist/**'
  --glob '!**/testdata/**'
  --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/test/**'
  --glob '!**/samples/**' --glob '!**/Samples/**' --glob '!**/examples/**'
  --glob '!**/example/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure ;; / (; comment-only lines (wat line comments).
  rg -v 'wasm-rg-allow' "$ALL" 2>/dev/null \
    | rg -v ':[0-9]+:[[:space:]]*;;' \
    | rg -v ':[0-9]+:[[:space:]]*\(;' >"$FILT" || true
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

  # memory_grow: drop hits whose source text already has a ;; comment (bound documented).
  if [[ "$id" == "memory_grow" && -s "$hitfile" ]]; then
    : >"$TMPDIR_GATE/hit.$id.nc"
    while IFS= read -r line || [[ -n "$line" ]]; do
      rest="${line#*:}"
      src="${rest#*:}"
      if echo "$src" | rg -q ';;'; then
        continue
      fi
      echo "$line" >>"$TMPDIR_GATE/hit.$id.nc"
    done <"$hitfile"
    mv "$TMPDIR_GATE/hit.$id.nc" "$hitfile"
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
echo "PASS wasm-rg-gate (${TARGETS[*]}, single-walk)"
