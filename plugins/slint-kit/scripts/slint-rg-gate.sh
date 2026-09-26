#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Slint smells (portable regex bar).
# PSR: leftover debug() banned in .slint; clone_strong banned (prefer as_weak in callbacks);
#      unsafe { blocks banned in Rust files that register .on_ callbacks.
# Language-farm. Product Slint compiler / clippy remain authoritative for depth;
# this gate is the portable rg bar for Slint trust smells.
#
# Usage: bash scripts/slint-rg-gate.sh [root] [path ...]
# Default scan: SLINT_RG_SRC or . Escape hatch: slint-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for slint-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${SLINT_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${SLINT_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(debug_slint clone_strong unsafe_block)
SCAN_PATS=(
  '\bdebug\s*\('
  '\bclone_strong\s*\('
  '\bunsafe\s*\{'
)
CLASS_PATS=(
  '\bdebug\s*\('
  '\bclone_strong\s*\('
  '\bunsafe\s*\{'
)
MSGS=(
  'debug() in .slint banned (leftover hygiene; prefer remove before merge / SLINT_DEBUG_PERFORMANCE env; slint-rg-allow with rationale)'
  'clone_strong() banned for Slint callback capture (prefer as_weak / upgrade / upgrade_in_event_loop; slint-rg-allow with rationale)'
  'unsafe { in Slint .on_ callback host banned (prefer safe path or named SAFETY boundary; slint-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.slint' --glob '*.rs'
  --glob '*.SLINT' --glob '*.RS'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/target/**' --glob '!**/build/**' --glob '!**/dist/**'
  --glob '!**/testdata/**'
  --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/test/**'
  --glob '!**/*_test.rs' --glob '!**/*_tests.rs' --glob '!**/tests.rs'
  --glob '!**/samples/**' --glob '!**/Samples/**' --glob '!**/examples/**'
  --glob '!**/example/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (// in .rs/.slint; //! doc-line noise kept if code present).
  rg -v 'slint-rg-allow' "$ALL" 2>/dev/null \
    | rg -v ':[0-9]+:[[:space:]]*//' >"$FILT" || true
else
  : >"$FILT"
fi

report_fail() {
  echo "FAIL: $1"
  head -40 "$2"
  local n; n=$(wc -l <"$2" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
}

# Map path -> whether file also registers a Slint .on_ callback (for unsafe_block scope).
ON_FILES="$TMPDIR_GATE/on_files"
: >"$ON_FILES"
if [[ -s "$FILT" ]]; then
  # Discover .on_ hosts among files that already hit (cheap), plus a targeted scan for .on_
  rg -l -P --glob '*.rs' --glob '*.RS' \
    --glob '!**/.git/**' --glob '!**/target/**' --glob '!**/testdata/**' \
    --glob '!**/tests/**' --glob '!**/examples/**' --glob '!**/example/**' \
    '\.on_[A-Za-z_][A-Za-z0-9_]*\s*\(' "${TARGETS[@]}" >"$ON_FILES" 2>/dev/null || true
fi

classify_one() {
  local i="$1" id="${IDS[$i]}" cpat="${CLASS_PATS[$i]}"
  local hitfile="$TMPDIR_GATE/hit.$id" rcfile="$TMPDIR_GATE/rc.$id"
  : >"$hitfile"
  rg -P -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true

  # Scope unsafe_block to files that also register .on_ callbacks.
  if [[ "$id" == "unsafe_block" && -s "$hitfile" ]]; then
    local scoped="$TMPDIR_GATE/hit.$id.scoped"
    : >"$scoped"
    while IFS= read -r line; do
      local fpath="${line%%:*}"
      # rg -n path may be ./foo; normalize
      if rg -F -x -- "$fpath" "$ON_FILES" >/dev/null 2>&1 \
        || rg -F -x -- "./${fpath#./}" "$ON_FILES" >/dev/null 2>&1 \
        || rg -F -- "${fpath#./}" "$ON_FILES" >/dev/null 2>&1; then
        echo "$line" >>"$scoped"
      fi
    done <"$hitfile"
    mv "$scoped" "$hitfile"
  fi

  # Scope debug_slint to .slint files only (pattern may match rare Rust debug( ).
  if [[ "$id" == "debug_slint" && -s "$hitfile" ]]; then
    local scoped="$TMPDIR_GATE/hit.$id.scoped"
    rg '\.slint:' "$hitfile" >"$scoped" 2>/dev/null || : >"$scoped"
    # also match paths ending in .slint before :
    if [[ ! -s "$scoped" ]]; then
      rg -i '\.slint:' "$hitfile" >"$scoped" 2>/dev/null || : >"$scoped"
    fi
    # Keep lines whose path component ends with .slint
    : >"$TMPDIR_GATE/hit.$id.keep"
    while IFS= read -r line; do
      local fpath="${line%%:*}"
      case "$fpath" in
        *.slint|*.SLINT) echo "$line" >>"$TMPDIR_GATE/hit.$id.keep" ;;
      esac
    done <"$hitfile"
    mv "$TMPDIR_GATE/hit.$id.keep" "$hitfile"
  fi

  # Scope clone_strong to .rs only
  if [[ "$id" == "clone_strong" && -s "$hitfile" ]]; then
    : >"$TMPDIR_GATE/hit.$id.keep"
    while IFS= read -r line; do
      local fpath="${line%%:*}"
      case "$fpath" in
        *.rs|*.RS) echo "$line" >>"$TMPDIR_GATE/hit.$id.keep" ;;
      esac
    done <"$hitfile"
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
echo "PASS slint-rg-gate (${TARGETS[*]}, single-walk)"
