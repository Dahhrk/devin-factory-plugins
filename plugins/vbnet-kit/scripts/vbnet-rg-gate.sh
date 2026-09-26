#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Visual Basic .NET smells (portable regex bar).
# PSR: On Error Resume Next banned; Option Strict Off banned; Console.WriteLine banned in libs.
# Language-farm. Product Roslyn / Option Strict tooling remain authoritative for depth;
# this gate is the portable rg bar for VB.NET trust smells.
#
# Usage: bash scripts/vbnet-rg-gate.sh [root] [path ...]
# Default scan: VBNET_RG_SRC or . Escape hatch: vbnet-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P) for Option Strict / On Error word boundaries.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for vbnet-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${VBNET_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${VBNET_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(on_error_resume_next option_strict_off console_write)
SCAN_PATS=(
  '(?i)\bOn\s+Error\s+Resume\s+Next\b'
  '(?i)(?:\bOption\s+Strict\s+Off\b|<OptionStrict>\s*Off\s*</OptionStrict>)'
  '\bConsole\.(WriteLine|Write|Error\.Write(Line)?)\s*\('
)
CLASS_PATS=(
  '(?i)\bOn\s+Error\s+Resume\s+Next\b'
  '(?i)(?:\bOption\s+Strict\s+Off\b|<OptionStrict>\s*Off\s*</OptionStrict>)'
  '\bConsole\.(WriteLine|Write|Error\.Write(Line)?)\s*\('
)
MSGS=(
  'On Error Resume Next banned (prefer Try/Catch; vbnet-rg-allow with rationale)'
  'Option Strict Off banned (prefer Option Strict On / <OptionStrict>On</OptionStrict>; vbnet-rg-allow with rationale)'
  'Console.Write/WriteLine in libs banned (prefer ILogger / Trace; CLI Program.vb may Console with allow; vbnet-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.vb' --glob '*.vbproj'
  --glob '*.VB' --glob '*.VBPROJ'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/bin/**' --glob '!**/obj/**' --glob '!**/packages/**'
  --glob '!**/testdata/**'
  --glob '!**/tests/**' --glob '!**/Tests/**' --glob '!**/test/**'
  --glob '!**/*Test.vb' --glob '!**/*Tests.vb'
  --glob '!**/samples/**' --glob '!**/Samples/**' --glob '!**/examples/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and VB comment-only hits (' and REM and leading XML doc ''').
  rg -v 'vbnet-rg-allow' "$ALL" 2>/dev/null \
    | rg -v ':[0-9]+:[[:space:]]*('\''|REM\b)' >"$FILT" || true
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
echo "PASS vbnet-rg-gate (${TARGETS[*]}, single-walk)"
