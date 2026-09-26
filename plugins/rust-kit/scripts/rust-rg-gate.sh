#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Rust smells (portable regex bar).
# PSR: rustfmt, Clippy, cargo test; document unsafe invariants and FFI;
# avoid unchecked assumptions at external boundaries.
# Product Clippy / rustfmt remain authoritative for typed depth; this gate is
# the portable rg bar.
#
# Usage: bash scripts/rust-rg-gate.sh [root] [path ...]
# Default scan: RUST_RG_SRC or . Escape hatch: rust-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for rust-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${RUST_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${RUST_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# SCAN_PATS match source lines. CLASS_PATS match rg "path:line:code" output.
IDS=(unsafe transmute externc todounimp nomangle)
SCAN_PATS=(
  '\bunsafe\b'
  'mem::transmute|transmute_copy|\btransmute[[:space:]]*!'
  'extern[[:space:]]+"C"'
  '\b(todo!|unimplemented!)[[:space:]]*\('
  '#\[no_mangle\]'
)
CLASS_PATS=(
  '\bunsafe\b'
  'mem::transmute|transmute_copy|\btransmute[[:space:]]*!'
  'extern[[:space:]]+"C"'
  '\b(todo!|unimplemented!)[[:space:]]*\('
  '#\[no_mangle\]'
)
MSGS=(
  'unsafe without rust-rg-allow (document SAFETY invariants / FFI; prefer safe API)'
  'transmute / transmute_copy banned (prefer From/TryFrom; rust-rg-allow with rationale)'
  'extern "C" FFI boundary (document invariants; rust-rg-allow on named boundary)'
  'todo! / unimplemented! in prod path (finish or return Result; rust-rg-allow for scaffold)'
  '#[no_mangle] export (document ABI/FFI; rust-rg-allow on named boundary)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.rs' --glob '!**/target/**' --glob '!**/.git/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'rust-rg-allow' "$ALL" >"$FILT" || true
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
echo "PASS rust-rg-gate (${TARGETS[*]}, single-walk)"
