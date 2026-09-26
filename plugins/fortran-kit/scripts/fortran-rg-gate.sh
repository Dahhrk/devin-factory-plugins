#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Fortran smells (portable regex bar).
# PSR: fortitude lint; implicit none; no GOTO; checked I/O (iostat=).
# Language-farm. Product fortitude remains authoritative for depth; this
# gate is the portable rg bar for Fortran trust smells.
#
# Usage: bash scripts/fortran-rg-gate.sh [root] [path ...]
# Default scan: FORTRAN_RG_SRC or . Escape hatch: fortran-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for fortran-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${FORTRAN_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${FORTRAN_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(goto implicit_typing unchecked_io)
SCAN_PATS=(
  '(?i)\bgo\s*to\b'
  '(?i)\bimplicit\s+(?!none\b)\w+'
  '(?i)^\s*(open|read|write|close)\s*\('
)
CLASS_PATS=(
  '(?i)\bgo\s*to\b'
  '(?i)\bimplicit\s+(?!none\b)\w+'
  '(?i):[0-9]+:[[:space:]]*(open|read|write|close)\s*\('
)
MSGS=(
  'GOTO / GO TO banned (prefer select case / structured loops / return; fortran-rg-allow with rationale)'
  'Old-style implicit typing banned (prefer implicit none; fortran-rg-allow with rationale; fortitude C001)'
  'Unchecked I/O banned (open/read/write/close need iostat=; prefer iomsg=; fortran-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.f90' --glob '*.F90' --glob '*.f95' --glob '*.F95'
  --glob '*.f03' --glob '*.F03' --glob '*.f08' --glob '*.F08'
  --glob '*.f' --glob '*.F' --glob '*.fypp'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**'
  --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/cmake-build*/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (! ...). Fixed-form C comment rare; free-form ! primary.
  rg -v 'fortran-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*!' >"$FILT" || true
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

  # Drop goto hits that still look like prose after a bang on the same source line.
  if [[ "$id" == "goto" && -s "$hitfile" ]]; then
    rg -v ':[0-9]+:.*!.*(?i)\bgo\s*to\b' "$hitfile" >"$TMPDIR_GATE/hit.$id.nc" 2>/dev/null || true
    mv "$TMPDIR_GATE/hit.$id.nc" "$hitfile"
  fi

  # Unchecked I/O: keep only open/read/write/close lines lacking iostat=
  if [[ "$id" == "unchecked_io" && -s "$hitfile" ]]; then
    rg -vi 'iostat\s*=' "$hitfile" >"$TMPDIR_GATE/hit.$id.io" 2>/dev/null || true
    mv "$TMPDIR_GATE/hit.$id.io" "$hitfile"
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

# File-level: program/module units must contain implicit none.
# Two files-with-matches passes (not per-file rg); excludes pure submodules.
MISSING="$TMPDIR_GATE/missing_implicit"
UNITS="$TMPDIR_GATE/units"
HAS_NONE="$TMPDIR_GATE/has_none"
SUBS="$TMPDIR_GATE/subs"
: >"$MISSING"
rg -l -i -P "${rg_globs[@]}" '(?m)^\s*(program|module)\b' "${TARGETS[@]}" >"$UNITS" 2>/dev/null || true
rg -l -i -P "${rg_globs[@]}" '(?i)\bimplicit\s+none\b' "${TARGETS[@]}" >"$HAS_NONE" 2>/dev/null || true
rg -l -i -P "${rg_globs[@]}" '(?m)^\s*submodule\b' "${TARGETS[@]}" >"$SUBS" 2>/dev/null || true
if [[ -s "$UNITS" ]]; then
  # Missing = units - has_none - (subs that are not also program/module-only handled via units already)
  # Drop files that are submodule-only: in SUBS and the only unit marker is submodule (no program/module).
  # UNITS already requires program|module, so submodule-only files are absent from UNITS.
  sort -u "$UNITS" >"$TMPDIR_GATE/units.u"
  sort -u "$HAS_NONE" >"$TMPDIR_GATE/has_none.u"
  comm -23 "$TMPDIR_GATE/units.u" "$TMPDIR_GATE/has_none.u" >"$MISSING" || true
fi
if [[ -s "$MISSING" ]]; then
  report_fail "program/module missing implicit none (prefer implicit none; fortitude C001; fortran-rg-allow not applicable file-wide — add the statement)" "$MISSING"
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS fortran-rg-gate (${TARGETS[*]}, single-walk)"
