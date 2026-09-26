#!/usr/bin/env bash
# Tier 0: Programming Standards Reference PHP smells (portable regex bar).
# PSR: Pint/php-cs-fixer + phpstan/psalm; no-eval; no unserialize of untrusted
# input; no SQL string concat with variables. Language-farm practical encode.
# Product Pint/phpstan remain authoritative for depth; this gate is the portable
# rg bar for PHP trust smells.
#
# Usage: bash scripts/php-rg-gate.sh [root] [path ...]
# Default scan: PHP_RG_SRC or . Escape hatch: php-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for php-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${PHP_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${PHP_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(eval_call unserialize sql_concat)
SCAN_PATS=(
  '\beval\s*\('
  '\bunserialize\s*\('
  '"(SELECT|INSERT|UPDATE|DELETE)[^"]*"\s*\.\s*\$|->(whereRaw|selectRaw|orderByRaw|havingRaw|fromRaw|joinRaw)\s*\([^;]*\.\s*\$'
)
CLASS_PATS=(
  '\beval\s*\('
  '\bunserialize\s*\('
  '"(SELECT|INSERT|UPDATE|DELETE)[^"]*"\s*\.\s*\$|->(whereRaw|selectRaw|orderByRaw|havingRaw|fromRaw|joinRaw)\s*\([^;]*\.\s*\$'
)
MSGS=(
  'eval( banned (prefer parsers / explicit dispatch; php-rg-allow with rationale)'
  'unserialize( banned (prefer json_decode / allowlisted classes; php-rg-allow with rationale)'
  'SQL string concat banned (SELECT/INSERT/UPDATE/DELETE literal . $var or whereRaw/selectRaw concat; prefer binds / query builder; php-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.php' --glob '*.phtml' --glob '!**/.git/**' --glob '!**/vendor/**' --glob '!**/tmp/**' --glob '!**/node_modules/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/*.test.php' --glob '!**/*Test.php' --glob '!**/examples/**' --glob '!**/fixtures/**' --glob '!**/storage/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading // or * after line num).
  rg -v 'php-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|\*|\#)' >"$FILT" || true
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
echo "PASS php-rg-gate (${TARGETS[*]}, single-walk)"
