#!/usr/bin/env bash
# Tier 0: Programming Standards Reference CMake smells (portable regex bar).
# PSR: no file(DOWNLOAD) without hash; no unchecked execute_process;
# no GLOB for sources; no CACHE FORCE abuse; no include of untrusted path.
# Language-farm. Product cmake --warn-uninitialized / policy / linter remains
# authoritative; this gate is the portable rg bar for CMake trust smells.
#
# Usage: bash scripts/cmake-rg-gate.sh [root] [path ...]
# Default scan: CMAKE_RG_SRC or . Escape hatch: cmake-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers CMakeLists.txt / *.cmake / *.cmake.in.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for cmake-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${CMAKE_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${CMAKE_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level; same-line bar for DOWNLOAD / execute_process like dockerfile apt)
IDS=(download_no_hash execute_process_unchecked glob_sources cache_force include_untrusted)
SCAN_PATS=(
  '(?i)\bfile\s*\(\s*DOWNLOAD\b(?![^\n]*(?:EXPECTED_HASH|EXPECTED_MD5)\b)'
  '(?i)\bexecute_process\s*\((?![^\n]*(?:RESULT_VARIABLE|RESULTS_VARIABLE|COMMAND_ERROR_IS_FATAL)\b)'
  '(?i)\bfile\s*\(\s*GLOB(?:_RECURSE)?\b[^\n]*\*\.(?:c|cc|cpp|cxx|cu|h|hh|hpp|hxx|m|mm)\b'
  '(?i)\bset\s*\([^\n]*\bCACHE\b[^\n]*\bFORCE\b'
  '(?i)\binclude\s*\(\s*(?:\$\{|["'\'']\$\{(?!(?:CMAKE_(?:CURRENT_)?(?:SOURCE|LIST|BINARY)_DIR|PROJECT_SOURCE_DIR)\}))'
)
CLASS_PATS=(
  '(?i):[0-9]+:.*\bfile\s*\(\s*DOWNLOAD\b(?![^\n]*(?:EXPECTED_HASH|EXPECTED_MD5)\b)'
  '(?i):[0-9]+:.*\bexecute_process\s*\((?![^\n]*(?:RESULT_VARIABLE|RESULTS_VARIABLE|COMMAND_ERROR_IS_FATAL)\b)'
  '(?i):[0-9]+:.*\bfile\s*\(\s*GLOB(?:_RECURSE)?\b[^\n]*\*\.(?:c|cc|cpp|cxx|cu|h|hh|hpp|hxx|m|mm)\b'
  '(?i):[0-9]+:.*\bset\s*\([^\n]*\bCACHE\b[^\n]*\bFORCE\b'
  '(?i):[0-9]+:.*\binclude\s*\(\s*(?:\$\{|["'\'']\$\{(?!(?:CMAKE_(?:CURRENT_)?(?:SOURCE|LIST|BINARY)_DIR|PROJECT_SOURCE_DIR)\}))'
)

MSGS=(
  'file(DOWNLOAD) without hash banned (file(DOWNLOAD ...) missing EXPECTED_HASH / EXPECTED_MD5 on same line; prefer EXPECTED_HASH SHA256=...; cmake-rg-allow with rationale)'
  'unchecked execute_process banned (execute_process without RESULT_VARIABLE / RESULTS_VARIABLE / COMMAND_ERROR_IS_FATAL on same line; cmake-rg-allow with rationale)'
  'GLOB for sources banned (file(GLOB|GLOB_RECURSE) collecting *.{c,cc,cpp,cxx,cu,h,hh,hpp,hxx,m,mm}; prefer explicit source lists; cmake-rg-allow with rationale)'
  'CACHE FORCE abuse banned (set(... CACHE ... FORCE); prefer set without FORCE or option(); cmake-rg-allow with rationale)'
  'include of untrusted path banned (include(${...}) variable / untrusted path; prefer static include(ModuleName) or vetted source-tree path; cmake-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob 'CMakeLists.txt' --glob '*.cmake' --glob '*.cmake.in'
  --glob '**/CMakeLists.txt' --glob '**/*.cmake' --glob '**/*.cmake.in'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
  --glob '!**/CMakeFiles/**' --glob '!**/Testing/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure comment lines (# cmake comments).
  rg -v 'cmake-rg-allow' "$ALL" 2>/dev/null \
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
echo "PASS cmake-rg-gate (${TARGETS[*]}, single-walk)"
