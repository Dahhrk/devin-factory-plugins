#!/usr/bin/env bash
# Tier 0: Programming Standards Reference C++ smells (portable regex bar).
# PSR: clang-format; -Wall -Wextra; clang-tidy; modern ownership/casts.
# Practical encode (language-farm): raw new/delete, C-style casts, sprintf/vsprintf.
# Product clang-format / -Wall -Wextra / clang-tidy remain authoritative for depth;
# this gate is the portable rg bar for modern C++ smells.
#
# Usage: bash scripts/cpp-rg-gate.sh [root] [path ...]
# Default scan: CPP_RG_SRC or . Escape hatch: cpp-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for cpp-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${CPP_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${CPP_RG_SRC})
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
IDS=(raw_new raw_delete c_cast sprintf)
SCAN_PATS=(
  '\bnew[[:space:]]+[A-Za-z_][A-Za-z0-9_:<>,[:space:]]*[\(\[]'
  '\bdelete[[:space:]]*(\[[^\]]*\]|[[:space:]]+[A-Za-z_~])'
  '(?:^|[^[:alnum:]_])\([[:space:]]*(?:const[[:space:]]+)?(?:unsigned[[:space:]]+)?(?:void|char|short|int|long|float|double|bool|size_t|u?int[0-9]+_t)[[:space:]]*\*+[[:space:]]*\)[[:space:]]*(?:[[:alnum:]_(]|&[[:alpha:]_])|(?:^|[^[:alnum:]_])\([[:space:]]*(?:unsigned[[:space:]]+)?(?:char|short|int|long|float|double|bool|size_t|u?int[0-9]+_t)[[:space:]]*\)[[:space:]]*(?:[[:alnum:]_(]|&[[:alpha:]_])'
  '\b(sprintf|vsprintf)[[:space:]]*\('
)
CLASS_PATS=(
  '\bnew[[:space:]]+[A-Za-z_][A-Za-z0-9_:<>,[:space:]]*[\(\[]'
  '\bdelete[[:space:]]*(\[[^\]]*\]|[[:space:]]+[A-Za-z_~])'
  '(?:^|[^[:alnum:]_])\([[:space:]]*(?:const[[:space:]]+)?(?:unsigned[[:space:]]+)?(?:void|char|short|int|long|float|double|bool|size_t|u?int[0-9]+_t)[[:space:]]*\*+[[:space:]]*\)[[:space:]]*(?:[[:alnum:]_(]|&[[:alpha:]_])|(?:^|[^[:alnum:]_])\([[:space:]]*(?:unsigned[[:space:]]+)?(?:char|short|int|long|float|double|bool|size_t|u?int[0-9]+_t)[[:space:]]*\)[[:space:]]*(?:[[:alnum:]_(]|&[[:alpha:]_])'
  '\b(sprintf|vsprintf)[[:space:]]*\('
)
MSGS=(
  'raw new banned (prefer unique_ptr/make_unique; cpp-rg-allow with rationale)'
  'raw delete banned (prefer unique_ptr RAII; cpp-rg-allow with rationale)'
  'C-style cast banned (prefer static_cast/reinterpret_cast/const_cast; cpp-rg-allow with rationale)'
  'sprintf/vsprintf banned (prefer fmt/std::format/snprintf; cpp-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.cpp' --glob '*.cc' --glob '*.cxx' --glob '*.hpp' --glob '*.hh' --glob '*.h' --glob '!**/build/**' --glob '!**/cmake-build*/**' --glob '!**/.git/**' --glob '!**/out/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/third_party/**' --glob '!**/vendor/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows, = delete (deleted special members), and comment-only hits.
  rg -v 'cpp-rg-allow|=[[:space:]]*delete' "$ALL" 2>/dev/null \
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
echo "PASS cpp-rg-gate (${TARGETS[*]}, single-walk)"
