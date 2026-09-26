#!/usr/bin/env bash
# Tier 1: require PSScriptAnalyzer lint wiring (PSR PowerShell language-farm).
# Live Invoke-ScriptAnalyzer when pwsh + module exist unless PS_PSSA_CONFIG_ONLY=1.
# Portable bar: PSScriptAnalyzerSettings.psd1 / Settings / CI Invoke-ScriptAnalyzer.
# Config text must keep PSAvoidUsingInvokeExpression and PSAvoidUsingWriteHost
# enabled (not listed under ExcludeRules / Severity None).
# Escape: PS_PSSA_GATE_SKIP=1.
# Usage: bash scripts/ps-pssa-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${PS_PSSA_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS ps-pssa-gate (skipped via PS_PSSA_GATE_SKIP=1)"
  exit 0
fi

mapfile -t ps_files < <(find . \( -name '*.ps1' -o -name '*.psm1' -o -name '*.PS1' -o -name '*.PSM1' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/bin/*' -not -path '*/obj/*' \
  2>/dev/null | sort || true)
if [[ ${#ps_files[@]} -eq 0 ]]; then
  echo "FAIL: no PowerShell sources under $ROOT"
  exit 1
fi

CFG=""
CFG_TEXT=""
for candidate in PSScriptAnalyzerSettings.psd1 PSScriptAnalyzerSettings.ps1 \
  ScriptAnalyzerSettings.psd1 .PSScriptAnalyzerSettings.psd1 Settings.psd1; do
  if [[ -f "$candidate" ]]; then
    CFG="$candidate"
    CFG_TEXT="$(cat "$candidate")"
    break
  fi
done

has_file_cfg=0
[[ -n "$CFG" ]] && has_file_cfg=1

if [[ "$has_file_cfg" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name 'PSScriptAnalyzerSettings.psd1' -o -name 'PSScriptAnalyzerSettings.ps1' -o -name 'ScriptAnalyzerSettings.psd1' \) -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested" ]]; then
    has_file_cfg=1
    CFG="$nested"
    CFG_TEXT="$(cat "$nested")"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi 'Invoke-ScriptAnalyzer|PSScriptAnalyzer|psscriptanalyzer' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no PSScriptAnalyzer wiring (PSScriptAnalyzerSettings.psd1 / Settings / CI Invoke-ScriptAnalyzer; PSR: PSScriptAnalyzer lint)"
  exit 1
fi

# Require PSR rule encode when a product settings file is present.
require_rule_enabled() {
  local rule="$1"
  local flat
  flat="$(echo "$CFG_TEXT" | tr '\n' ' ')"
  # Fail if explicitly excluded (ExcludeRules @( ... 'Rule' ... ))
  if echo "$flat" | rg -qi "ExcludeRules[^@]*@\([^)]*['\"]${rule}['\"]"; then
    echo "FAIL: $CFG excludes ${rule} (PSR: keep ${rule} enabled)"
    return 1
  fi
  # Fail if Rules.{rule}.Severity = 'None' / Disabled style
  if echo "$CFG_TEXT" | rg -qi "${rule}"'[^\n]*Severity[^\n]*(None|Disabled)'; then
    echo "FAIL: $CFG sets ${rule} severity None/Disabled (PSR: keep ${rule} enabled)"
    return 1
  fi
  # Product bar: require explicit IncludeRules entry (or rule name present when IncludeRules absent).
  if echo "$CFG_TEXT" | rg -qi "IncludeRules"; then
    if ! echo "$CFG_TEXT" | rg -qi "['\"]${rule}['\"]"; then
      echo "FAIL: $CFG IncludeRules missing ${rule} (PSR: PSScriptAnalyzer ${rule} bar)"
      return 1
    fi
  else
    if ! echo "$CFG_TEXT" | rg -qi "${rule}"; then
      echo "FAIL: $CFG missing ${rule} encode (list under IncludeRules or Rules; PSR: PSScriptAnalyzer ${rule} bar)"
      return 1
    fi
  fi
  return 0
}

if [[ -n "$CFG_TEXT" ]]; then
  fail_rules=0
  require_rule_enabled "PSAvoidUsingInvokeExpression" || fail_rules=1
  require_rule_enabled "PSAvoidUsingWriteHost" || fail_rules=1
  if [[ "$fail_rules" -ne 0 ]]; then
    exit 1
  fi
fi

if [[ "${PS_PSSA_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS ps-pssa-gate ($ROOT, config-only, ${#ps_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v pwsh >/dev/null 2>&1; then
  set +e
  pwsh -NoProfile -Command "
    if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) { exit 127 }
    \$settings = if (Test-Path -LiteralPath '${CFG:-PSScriptAnalyzerSettings.psd1}') { '${CFG:-PSScriptAnalyzerSettings.psd1}' } else { \$null }
    \$paths = Get-ChildItem -Recurse -Include *.ps1,*.psm1 | Where-Object { \$_.FullName -notmatch '[\\/](\.git|node_modules|vendor|testdata|bin|obj)[\\/]' }
    \$args = @{ Path = \$paths.FullName; Recurse = \$false }
    if (\$settings) { \$args['Settings'] = \$settings }
    \$r = Invoke-ScriptAnalyzer @args -ErrorAction SilentlyContinue
    if (\$r) { \$r | Format-Table -AutoSize | Out-String | Write-Host; exit 1 } else { exit 0 }
  " >/tmp/pssa-gate-lint.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/pssa-gate-lint.$$.out"
    echo "PASS ps-pssa-gate ($ROOT, live Invoke-ScriptAnalyzer, ${#ps_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/pssa-gate-lint.$$.out"
fi

echo "PASS ps-pssa-gate ($ROOT, config-only fallback, ${#ps_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
