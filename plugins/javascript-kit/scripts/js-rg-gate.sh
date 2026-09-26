#!/usr/bin/env bash
# Tier 0: Programming Standards Reference JS smells (portable regex bar).
# PSR: ESLint + formatter; explicit async errors; avoid coercion surprises;
# server-side input checks. Language-farm practical encode: no-eval,
# prototype-pollution smells, sync fs on request path.
# Product ESLint / Prettier remain authoritative for depth; this gate is the
# portable rg bar for JS trust smells. Distinct from typescript-kit.
#
# Usage: bash scripts/js-rg-gate.sh [root] [path ...]
# Default scan: JS_RG_SRC or . Escape hatch: js-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for js-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${JS_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${JS_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(eval_call proto_pollute sync_fs)
SCAN_PATS=(
  '\beval\s*\(|\bnew\s+Function\s*\('
  '__proto__|constructor\s*\.\s*prototype\b|constructor\s*\[\s*["'"'"']prototype["'"'"']\s*\]|Object\.assign\s*\([^,]+,\s*(req\.(body|query|params)|request\.(body|query|params))\b'
  '\bfs\.(readFileSync|writeFileSync|existsSync|statSync|readdirSync|mkdirSync|appendFileSync|accessSync|realpathSync|unlinkSync|renameSync|copyFileSync|openSync|readSync|writeSync)\s*\(|\b(readFileSync|writeFileSync|existsSync|statSync|readdirSync|mkdirSync|appendFileSync|accessSync|realpathSync|unlinkSync|renameSync|copyFileSync|openSync)\s*\('
)
CLASS_PATS=(
  '\beval\s*\(|\bnew\s+Function\s*\('
  '__proto__|constructor\s*\.\s*prototype\b|constructor\s*\[\s*["'"'"']prototype["'"'"']\s*\]|Object\.assign\s*\([^,]+,\s*(req\.(body|query|params)|request\.(body|query|params))\b'
  '\bfs\.(readFileSync|writeFileSync|existsSync|statSync|readdirSync|mkdirSync|appendFileSync|accessSync|realpathSync|unlinkSync|renameSync|copyFileSync|openSync|readSync|writeSync)\s*\(|\b(readFileSync|writeFileSync|existsSync|statSync|readdirSync|mkdirSync|appendFileSync|accessSync|realpathSync|unlinkSync|renameSync|copyFileSync|openSync)\s*\('
)
MSGS=(
  'eval / new Function banned (prefer Function body as data + parsers; js-rg-allow with rationale)'
  'prototype-pollution smell banned (__proto__ / constructor.prototype / Object.assign onto req.body|query|params; prefer Object.create(null) merge; js-rg-allow with rationale)'
  'sync fs on request path banned (prefer fs.promises / async fs; js-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.js' --glob '*.mjs' --glob '*.cjs' --glob '*.jsx' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/coverage/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/*.test.js' --glob '!**/*.spec.js' --glob '!**/vendor/**' --glob '!**/examples/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading // or /* or * after line num).
  rg -v 'js-rg-allow' "$ALL" 2>/dev/null \
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
echo "PASS js-rg-gate (${TARGETS[*]}, single-walk)"
