#!/usr/bin/env bash
# Tier 1: require clasp / Apps Script project wiring (PSR Apps Script language-farm).
# Portable bar: .gs/.js Apps Script sources (or appsscript.json) present +
# .clasp.json / appsscript.json / package.json / CI mentioning clasp.
# Escape: APPS_SCRIPT_CLASP_GATE_SKIP=1.
# Usage: bash scripts/apps-script-clasp-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${APPS_SCRIPT_CLASP_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS apps-script-clasp-gate (skipped via APPS_SCRIPT_CLASP_GATE_SKIP=1)"
  exit 0
fi

mapfile -t gas_files < <(find . \( \
  -name '*.gs' -o -name 'appsscript.json' -o -name '.clasp.json' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' \
  -not -path '*/testdata/*' -not -path '*/tests/*' -not -path '*/Tests/*' \
  -not -path '*/examples/*' -not -path '*/example/*' \
  2>/dev/null | sort || true)
if [[ ${#gas_files[@]} -eq 0 ]]; then
  echo "FAIL: no Apps Script sources (.gs / appsscript.json / .clasp.json) under $ROOT"
  exit 1
fi

WIRE_PAT='clasp|@google/clasp|appsscript\.json'
has_wiring=0
CFG=""
for mf in .clasp.json appsscript.json package.json package-lock.json; do
  if [[ -f "$mf" ]]; then
    if [[ "$mf" == ".clasp.json" || "$mf" == "appsscript.json" ]]; then
      has_wiring=1
      CFG="$mf"
      break
    fi
    if rg -qiP "$WIRE_PAT" "$mf" 2>/dev/null; then
      has_wiring=1
      CFG="$mf"
      break
    fi
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP 'clasp|apps.?script|appsscript' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no clasp / Apps Script wiring (.clasp.json / appsscript.json / package.json mentioning clasp; or CI with clasp; PSR: Apps Script toolchain)"
  exit 1
fi

if [[ "${APPS_SCRIPT_CLASP_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS apps-script-clasp-gate ($ROOT, config-only, ${#gas_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v clasp >/dev/null 2>&1 || command -v npx >/dev/null 2>&1; then
  live_rc=0
fi

echo "PASS apps-script-clasp-gate ($ROOT, config-only fallback, ${#gas_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
