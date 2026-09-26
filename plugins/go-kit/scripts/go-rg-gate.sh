#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Go smells (portable regex bar).
# PSR: propagate errors/cancellation; bound goroutines; close resources;
# avoid uncontrolled globals. Product golangci (errcheck/bodyclose) remains
# authoritative for typed depth; this gate is the portable rg bar.
#
# Usage: bash scripts/go-rg-gate.sh [root] [path ...]
# Default scan: GO_RG_SRC or . Escape hatch: go-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for go-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${GO_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${GO_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# SCAN_PATS match source lines. CLASS_PATS match rg "path:line:code" output
# (anchors apply to the code portion after path:line:).
IDS=(funchook barego ioutil paniccall errgroupbg)
SCAN_PATS=(
  '^var [A-Z][A-Za-z0-9_]*[[:space:]]*=[[:space:]]*func'
  '^[[:space:]]*go[[:space:]]'
  '\bioutil\.'
  '^[[:space:]]*panic[[:space:]]*\('
  'errgroup\.WithContext\([[:space:]]*context\.Background[[:space:]]*\([[:space:]]*\)[[:space:]]*\)'
)
CLASS_PATS=(
  ':[0-9]+:var [A-Z][A-Za-z0-9_]*[[:space:]]*=[[:space:]]*func'
  ':[0-9]+:[[:space:]]*go[[:space:]]'
  '\bioutil\.'
  ':[0-9]+:[[:space:]]*panic[[:space:]]*\('
  'errgroup\.WithContext\([[:space:]]*context\.Background[[:space:]]*\([[:space:]]*\)[[:space:]]*\)'
)
MSGS=(
  'exported package-level func hook (uncontrolled global); inject via param or go-rg-allow with rationale'
  'go launch (bound with WaitGroup/errgroup/ctx cancel, or go-rg-allow)'
  'deprecated ioutil (use io and os)'
  'panic( in prod path (prefer error return; go-rg-allow for must-init)'
  'errgroup.WithContext(context.Background()) (prefer request/parent ctx; do not drop cancel)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.go' --glob '!*_test.go' --glob '!**/vendor/**' --glob '!**/.git/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'go-rg-allow' "$ALL" >"$FILT" || true
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
echo "PASS go-rg-gate (${TARGETS[*]}, single-walk)"
