#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Objective-C smells (portable regex bar).
# PSR: clang-format; ARC (no manual retain/release/autorelease); no NSLog in libs;
# no performSelector: smells.
# Language-farm. Product clang-format / -Warc-performSelector-leaks remain
# authoritative for depth; this gate is the portable rg bar for ObjC trust smells.
#
# Usage: bash scripts/objc-rg-gate.sh [root] [path ...]
# Default scan: OBJC_RG_SRC or . Escape hatch: objc-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for objc-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${OBJC_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${OBJC_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(nslog perform_selector manual_retain)
SCAN_PATS=(
  '\bNSLog[[:space:]]*\('
  '\bperformSelector(?:OnMainThread|InBackground|OnThread)?[[:space:]]*:'
  '[[:space:]](?:retain|release|autorelease)[[:space:]]*\]'
)
CLASS_PATS=(
  '\bNSLog[[:space:]]*\('
  '\bperformSelector(?:OnMainThread|InBackground|OnThread)?[[:space:]]*:'
  '[[:space:]](?:retain|release|autorelease)[[:space:]]*\]'
)
MSGS=(
  'NSLog banned in libs (prefer os_log / injected logger; objc-rg-allow with rationale)'
  'performSelector: banned (prefer typed methods / blocks / proven IMP; objc-rg-allow with rationale)'
  'manual retain/release/autorelease banned under ARC (prefer ARC; CFRetain/CFRelease at CF bridge with allow; objc-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.m' --glob '*.h' --glob '*.mm' --glob '*.M'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/Pods/**' --glob '!**/Carthage/**' --glob '!**/DerivedData/**'
  --glob '!**/build/**' --glob '!**/Build/**' --glob '!**/dist/**'
  --glob '!**/testdata/**' --glob '!**/Examples/**' --glob '!**/examples/**'
  --glob '!**/Tests/**' --glob '!**/tests/**' --glob '!**/Test/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and ObjC // comment-only lines.
  rg -v 'objc-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*//' >"$FILT" || true
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
echo "PASS objc-rg-gate (${TARGETS[*]}, single-walk)"
