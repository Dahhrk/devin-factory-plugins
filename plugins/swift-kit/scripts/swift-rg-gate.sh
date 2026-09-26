#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Swift smells (portable regex bar).
# PSR: swift-format/SwiftFormat + SwiftLint; no force unwrap; no try!; no
# unchecked unsafe pointers. Language-farm practical encode.
# Product swift-format/SwiftLint remain authoritative for depth; this gate is
# the portable rg bar for Swift trust smells.
#
# Usage: bash scripts/swift-rg-gate.sh [root] [path ...]
# Default scan: SWIFT_RG_SRC or . Escape hatch: swift-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for swift-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${SWIFT_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${SWIFT_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# force_unwrap: postfix ! / IUO (excludes try! via classify filter; as! counts as force cast family)
IDS=(force_unwrap try_bang unsafe_ptr)
SCAN_PATS=(
  '[\w\)\]]!(?:[^\w=]|$)'
  '\btry!'
  '\bUnsafe(Mutable)?(Raw)?(Buffer)?Pointer\b|\bwithUnsafe|\bassumingMemoryBound'
)
CLASS_PATS=(
  '[\w\)\]]!(?:[^\w=]|$)'
  '\btry!'
  '\bUnsafe(Mutable)?(Raw)?(Buffer)?Pointer\b|\bwithUnsafe|\bassumingMemoryBound'
)
MSGS=(
  'force unwrap / force cast banned (prefer if let / guard let / ?? / as?; swift-rg-allow with rationale)'
  'try! banned (prefer try / Result; swift-rg-allow with rationale)'
  'unsafe pointer / withUnsafe / assumingMemoryBound banned (named boundary + lifetime docs; swift-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.swift' --glob '!**/.git/**' --glob '!**/tmp/**' --glob '!**/node_modules/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/*Tests.swift' --glob '!**/*Test.swift' --glob '!**/examples/**' --glob '!**/fixtures/**' --glob '!**/Benchmarks/**' --glob '!**/docs/**' --glob '!**/.build/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading // or * after line num).
  rg -v 'swift-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|\*)' >"$FILT" || true
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
  if [[ "$id" == "force_unwrap" ]]; then
    # Count force unwrap / as! / IUO; leave try! to try_bang.
    rg -- "$cpat" "$FILT" 2>/dev/null | rg -v '\btry!' >"$hitfile" || true
  else
    rg -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
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
echo "PASS swift-rg-gate (${TARGETS[*]}, single-walk)"
