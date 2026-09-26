#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Ruby smells (portable regex bar).
# PSR: RuboCop + rubocop-performance; handle dynamic behaviour carefully;
# validate inputs. Language-farm practical encode: no-eval, dynamic send smells,
# SQL string interpolate in where/order/select/find_by_sql.
# Product RuboCop remains authoritative for depth; this gate is the portable
# rg bar for Ruby trust smells.
#
# Usage: bash scripts/ruby-rg-gate.sh [root] [path ...]
# Default scan: RUBY_RG_SRC or . Escape hatch: ruby-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for ruby-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${RUBY_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${RUBY_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(eval_call send_smell sql_interp)
SCAN_PATS=(
  '\beval\s*\('
  '\b(send|__send__|public_send)\s*\(\s*(:"[^"]*#\{|"[^"]*#\{|params\b)'
  '\.(where|order|reorder|group|having|pluck|select|find_by_sql|delete_all|update_all)\s*\(\s*"[^"]*#\{'
)
CLASS_PATS=(
  '\beval\s*\('
  '\b(send|__send__|public_send)\s*\(\s*(:"[^"]*#\{|"[^"]*#\{|params\b)'
  '\.(where|order|reorder|group|having|pluck|select|find_by_sql|delete_all|update_all)\s*\(\s*"[^"]*#\{'
)
MSGS=(
  'eval( banned (prefer parsers / explicit dispatch; ruby-rg-allow with rationale)'
  'dynamic send smell banned (send/__send__/public_send with interpolated method name or params; prefer explicit methods or allowlisted dispatcher; ruby-rg-allow with rationale)'
  'SQL string interpolate in where/order/select/find_by_sql banned (prefer binds / hash conditions / Arel; ruby-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.rb' --glob '*.rake' --glob '!**/.git/**' --glob '!**/vendor/**' --glob '!**/tmp/**' --glob '!**/node_modules/**' --glob '!**/test/**' --glob '!**/spec/**' --glob '!**/tests/**' --glob '!**/*.test.rb' --glob '!**/*.spec.rb' --glob '!**/examples/**' --glob '!**/fixtures/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading # after line num).
  rg -v 'ruby-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*#' >"$FILT" || true
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
echo "PASS ruby-rg-gate (${TARGETS[*]}, single-walk)"
