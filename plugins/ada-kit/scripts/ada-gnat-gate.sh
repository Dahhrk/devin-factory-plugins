#!/usr/bin/env bash
# Tier 1: require gnatcheck and/or gnatpp wiring (PSR Ada language-farm).
# Live gnatcheck when present unless ADA_GNAT_CONFIG_ONLY=1.
# Portable bar: .gpr package Check / Pretty_Printer; gnatcheck.rules; CI gnatcheck|gnatpp.
# When a gnatcheck.rules (or -rules file) is present, Unchecked_Conversions must stay enabled
# (not ---Unchecked_Conversions).
# Escape: ADA_GNAT_GATE_SKIP=1.
# Usage: bash scripts/ada-gnat-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${ADA_GNAT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS ada-gnat-gate (skipped via ADA_GNAT_GATE_SKIP=1)"
  exit 0
fi

mapfile -t a_files < <(find . \( \
  -name '*.ads' -o -name '*.adb' -o -name '*.ada' -o -name '*.Ada' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/obj/*' \
  -not -path '*/alire/*' -not -path '*/.alire/*' \
  -not -path '*/testdata/*' \
  2>/dev/null | sort || true)
if [[ ${#a_files[@]} -eq 0 ]]; then
  echo "FAIL: no Ada sources under $ROOT"
  exit 1
fi

has_wiring=0
CFG=""
RULES_FILE=""

# Scan .gpr for package Check (gnatcheck) or Pretty_Printer (gnatpp)
mapfile -t gprs < <(find . -maxdepth 3 -type f \( -name '*.gpr' -o -name '*.GPR' \) \
  -not -path '*/.git/*' -not -path '*/obj/*' -not -path '*/alire/*' 2>/dev/null | sort || true)
for gpr in "${gprs[@]:-}"; do
  [[ -z "$gpr" ]] && continue
  if rg -qi 'package\s+Pretty_Printer\b|package\s+Check\b' "$gpr" 2>/dev/null; then
    has_wiring=1
    CFG="$gpr"
    break
  fi
  if rg -qi '\bgnatcheck\b|\bgnatpp\b' "$gpr" 2>/dev/null; then
    has_wiring=1
    CFG="$gpr"
    break
  fi
done

# Dedicated rules file
if [[ -f gnatcheck.rules ]]; then
  RULES_FILE="gnatcheck.rules"
  has_wiring=1
  CFG="${CFG:-gnatcheck.rules}"
elif [[ -f .gnatcheck ]]; then
  RULES_FILE=".gnatcheck"
  has_wiring=1
  CFG="${CFG:-.gnatcheck}"
else
  nested_rules="$(find . -maxdepth 3 -type f \( -name 'gnatcheck.rules' -o -name '.gnatcheck' \) \
    -not -path '*/.git/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested_rules" ]]; then
    RULES_FILE="$nested_rules"
    has_wiring=1
    CFG="${CFG:-$nested_rules}"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi '\bgnatcheck\b|\bgnatpp\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Makefile / alire mention
if [[ "$has_wiring" -eq 0 ]]; then
  for mf in Makefile makefile GNUmakefile alire.toml; do
    if [[ -f "$mf" ]] && rg -qi '\bgnatcheck\b|\bgnatpp\b' "$mf" 2>/dev/null; then
      has_wiring=1
      CFG="$mf"
      break
    fi
  done
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no gnatcheck/gnatpp wiring (.gpr package Check|Pretty_Printer / gnatcheck.rules / CI gnatcheck|gnatpp; PSR: gnatcheck/gnatpp)"
  exit 1
fi

# When rules file present, Unchecked_Conversions must not be disabled.
require_uc_rule_enabled() {
  local text="$1" label="$2"
  # gnatcheck disable form: ---Unchecked_Conversions (three dashes)
  if echo "$text" | rg -P -q '(?m)^[[:space:]]*---Unchecked_Conversions\b'; then
    echo "FAIL: $label disables Unchecked_Conversions (PSR: keep --+Unchecked_Conversions enabled)"
    return 1
  fi
  # If file enables any + rules, prefer seeing Unchecked_Conversions named; accept empty/+all defaults.
  if echo "$text" | rg -q '\-\-\+Unchecked_Conversions|\+Unchecked_Conversions'; then
    return 0
  fi
  # No explicit disable and no other --- rules targeting UC — accept (defaults / Check package alone).
  return 0
}

if [[ -n "$RULES_FILE" && -f "$RULES_FILE" ]]; then
  if ! require_uc_rule_enabled "$(cat "$RULES_FILE")" "$RULES_FILE"; then
    exit 1
  fi
fi

# Weak .gpr: present but neither Check nor Pretty_Printer — already handled unless only rules file.
# Additional weak: gpr exists without packages AND rules file disables UC — covered above.

if [[ "${ADA_GNAT_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS ada-gnat-gate ($ROOT, config-only, ${#a_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v gnatcheck >/dev/null 2>&1 && [[ -n "$CFG" && "$CFG" == *.gpr ]]; then
  set +e
  gnatcheck -P "$CFG" >/tmp/ada-gnatcheck-gate.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    echo "PASS ada-gnat-gate ($ROOT, live gnatcheck, ${#a_files[@]} files, cfg=$CFG)"
    exit 0
  fi
  echo "FAIL: gnatcheck -P $CFG exited $live_rc"
  head -40 /tmp/ada-gnatcheck-gate.$$.out
  rm -f /tmp/ada-gnatcheck-gate.$$.out
  exit 1
fi

echo "PASS ada-gnat-gate ($ROOT, config-only fallback, ${#a_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
