#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Elixir smells (portable regex bar).
# PSR: mix format + Credo + dialyzer; no String.to_atom on input; no SQL
# string concat; no Process.sleep on hot paths. Language-farm.
# Product mix format / Credo / dialyzer remain authoritative for depth; this
# gate is the portable rg bar for Elixir trust smells.
#
# Usage: bash scripts/elixir-rg-gate.sh [root] [path ...]
# Default scan: ELIXIR_RG_SRC or . Escape hatch: elixir-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for elixir-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${ELIXIR_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${ELIXIR_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(to_atom sql_concat process_sleep)
SCAN_PATS=(
  'String\.to_atom[[:space:]]*[\(/\[]'
  '"(SELECT|INSERT|UPDATE|DELETE|WITH)[^"]*#\{|"(SELECT|INSERT|UPDATE|DELETE|WITH)[^"]*"[[:space:]]*<>'
  'Process\.sleep[[:space:]]*\('
)
CLASS_PATS=(
  'String\.to_atom[[:space:]]*[\(/\[]'
  '"(SELECT|INSERT|UPDATE|DELETE|WITH)[^"]*#\{|"(SELECT|INSERT|UPDATE|DELETE|WITH)[^"]*"[[:space:]]*<>'
  'Process\.sleep[[:space:]]*\('
)
MSGS=(
  'String.to_atom banned on input paths (prefer String.to_existing_atom / allowlisted atoms; elixir-rg-allow with rationale)'
  'SQL string concat/interpolation banned (SELECT/INSERT/UPDATE/DELETE/WITH #{} or <> ; prefer Ecto binds / parameterized; elixir-rg-allow with rationale)'
  'Process.sleep banned on hot paths (prefer Process.send_after / receive / supervised backoff; elixir-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.ex' --glob '*.exs' --glob '!**/.git/**' --glob '!**/_build/**' --glob '!**/deps/**' --glob '!**/tmp/**' --glob '!**/node_modules/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/Test/**' --glob '!**/Tests/**' --glob '!**/*_test.exs' --glob '!**/examples/**' --glob '!**/fixtures/**' --glob '!**/priv/static/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading # after line num).
  rg -v 'elixir-rg-allow' "$ALL" 2>/dev/null \
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
echo "PASS elixir-rg-gate (${TARGETS[*]}, single-walk)"
