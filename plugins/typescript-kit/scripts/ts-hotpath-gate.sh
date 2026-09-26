#!/usr/bin/env bash
# Tier 0.5: wall-clock budget for ts-rg-gate (kit hot-path EXIT).
# Measured 2026-09-26 (Europe/London) on single-walk gate:
#   good fixture ~45ms; eslint/lib ~60ms; hop-common ~90ms;
#   payload/src ~95ms; cal apps/web ~95ms.
# Default budget 250ms (headroom for loaded CI). Override: TS_RG_BUDGET_MS.
# Usage: bash scripts/ts-hotpath-gate.sh [root]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
BUDGET_MS="${TS_RG_BUDGET_MS:-250}"

if ! [[ "$BUDGET_MS" =~ ^[0-9]+$ ]] || [[ "$BUDGET_MS" -lt 1 ]]; then
  echo "FAIL: TS_RG_BUDGET_MS must be a positive integer (ms)"
  exit 1
fi

start_ns=$(date +%s%N)
set +e
bash "$HERE/ts-rg-gate.sh" "$ROOT" >"/tmp/ts-hotpath-rg.$$.out" 2>&1
rg_rc=$?
set -e
end_ns=$(date +%s%N)
elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
cat "/tmp/ts-hotpath-rg.$$.out"
rm -f "/tmp/ts-hotpath-rg.$$.out"

if [[ "$elapsed_ms" -gt "$BUDGET_MS" ]]; then
  echo "FAIL: ts-rg-gate wall ${elapsed_ms}ms exceeds budget ${BUDGET_MS}ms (TS_RG_BUDGET_MS)"
  exit 1
fi

# Smell failures still fail the hotpath gate (budget is additive EXIT)
if [[ "$rg_rc" -ne 0 ]]; then
  echo "FAIL: ts-rg-gate exit $rg_rc within budget ${elapsed_ms}ms/${BUDGET_MS}ms"
  exit "$rg_rc"
fi
echo "PASS ts-hotpath-gate ($ROOT, ${elapsed_ms}ms <= ${BUDGET_MS}ms)"
