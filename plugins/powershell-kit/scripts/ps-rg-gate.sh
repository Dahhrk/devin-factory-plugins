#!/usr/bin/env bash
# Tier 0: Programming Standards Reference PowerShell smells (portable regex bar).
# PSR: PSScriptAnalyzer lint; no Invoke-Expression; no Write-Host in modules;
# no unquoted path cmdlet args.
# Language-farm. Product PSScriptAnalyzer remains authoritative for depth; this
# gate is the portable rg bar for PowerShell trust smells.
#
# Usage: bash scripts/ps-rg-gate.sh [root] [path ...]
# Default scan: PS_RG_SRC or . Escape hatch: ps-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for ps-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${PS_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${PS_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(invoke_expression write_host_module unquoted_path)
SCAN_PATS=(
  '(?i)\bInvoke-Expression\b|\biex\b'
  '(?i)\bWrite-Host\b'
  '(?i)\b(?:Set-Location|Push-Location|Get-Content|Set-Content|Add-Content|Out-File|Copy-Item|Move-Item|Remove-Item|Test-Path|New-Item|Get-ChildItem|Resolve-Path)\s+\$[A-Za-z_]'
)
CLASS_PATS=(
  '(?i)\bInvoke-Expression\b|\biex\b'
  '(?i)\bWrite-Host\b'
  '(?i)\b(?:Set-Location|Push-Location|Get-Content|Set-Content|Add-Content|Out-File|Copy-Item|Move-Item|Remove-Item|Test-Path|New-Item|Get-ChildItem|Resolve-Path)\s+\$[A-Za-z_]'
)
MSGS=(
  'Invoke-Expression / iex banned (prefer & call operator / splatting; ps-rg-allow with rationale; PSScriptAnalyzer PSAvoidUsingInvokeExpression)'
  'Write-Host in modules (.psm1) banned (prefer Write-Output / information stream; ps-rg-allow with rationale; PSScriptAnalyzer PSAvoidUsingWriteHost)'
  'Unquoted path cmdlet arg banned (quote "$path"; ps-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.ps1' --glob '*.psm1' --glob '*.PS1' --glob '*.PSM1' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/bin/**' --glob '!**/obj/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (# ... or <# ...).
  rg -v 'ps-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*#' \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*<#' >"$FILT" || true
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
  # Write-Host smell only applies inside modules (.psm1)
  if [[ "$id" == "write_host_module" && -s "$hitfile" ]]; then
    rg '\.psm1:' "$hitfile" >"$TMPDIR_GATE/hit.$id.mod" 2>/dev/null || true
    mv "$TMPDIR_GATE/hit.$id.mod" "$hitfile"
  fi
  # iex false-positives: avoid matching inside longer identifiers via word boundary already;
  # still drop pure documentation lines that only mention the cmdlet name in prose after # (already dropped).
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
echo "PASS ps-rg-gate (${TARGETS[*]}, single-walk)"
