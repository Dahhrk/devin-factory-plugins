#!/usr/bin/env bash
# Tier 0: Programming Standards Reference C# smells (portable regex bar).
# PSR: .editorconfig / Roslyn analyzers / dotnet format; nullable; SQL/string concat;
# Console.WriteLine in libs; avoid blocking on async.
# Practical encode (language-farm): Console.Write/WriteLine/Error.Write, SQL string
# concat, blocking-on-async (.Result / .Wait( / GetAwaiter().GetResult()).
# Product formatter / analyzers / nullable tooling remain authoritative for depth;
# this gate is the portable rg bar for C# trust smells.
#
# Usage: bash scripts/csharp-rg-gate.sh [root] [path ...]
# Default scan: CSHARP_RG_SRC or . Escape hatch: csharp-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for csharp-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${CSHARP_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${CSHARP_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(console_write sql_concat block_async)
SCAN_PATS=(
  '\bConsole\.(WriteLine|Write|Error\.Write(Line)?)\s*\('
  '"(SELECT|INSERT|UPDATE|DELETE|WITH)[[:space:]][^"]*"[[:space:]]*\+|\+[[:space:]]*"(SELECT|INSERT|UPDATE|DELETE|[[:space:]]+WHERE|[[:space:]]+FROM|[[:space:]]+AND|[[:space:]]+OR)[^"]*"'
  '\.GetAwaiter\s*\(\s*\)\s*\.GetResult\s*\(|\.Result\b|\.Wait\s*\('
)
CLASS_PATS=(
  '\bConsole\.(WriteLine|Write|Error\.Write(Line)?)\s*\('
  '"(SELECT|INSERT|UPDATE|DELETE|WITH)[[:space:]][^"]*"[[:space:]]*\+|\+[[:space:]]*"(SELECT|INSERT|UPDATE|DELETE|[[:space:]]+WHERE|[[:space:]]+FROM|[[:space:]]+AND|[[:space:]]+OR)[^"]*"'
  '\.GetAwaiter\s*\(\s*\)\s*\.GetResult\s*\(|\.Result\b|\.Wait\s*\('
)
MSGS=(
  'Console.Write/WriteLine in libs banned (prefer ILogger; csharp-rg-allow with rationale)'
  'SQL/string concat banned (prefer parameterized SqlCommand / Dapper; csharp-rg-allow with rationale)'
  'blocking on async banned (.Result / .Wait( / GetAwaiter().GetResult(); prefer await; csharp-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.cs' --glob '!**/.git/**' --glob '!**/bin/**' --glob '!**/obj/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/*Test.cs' --glob '!**/*Tests.cs' --glob '!**/generated/**' --glob '!**/vendor/**' --glob '!**/packages/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (leading // or /* or * after line num).
  rg -v 'csharp-rg-allow' "$ALL" 2>/dev/null \
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
echo "PASS csharp-rg-gate (${TARGETS[*]}, single-walk)"
