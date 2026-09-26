#!/usr/bin/env bash
# Tier 0.5: wall-clock budget for vbnet-rg-gate (kit hot-path EXIT).
# Default budget 250ms (headroom for loaded CI). Override: VBNET_RG_BUDGET_MS.
# Usage: bash scripts/vbnet-hotpath-gate.sh [root] [path ...]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
shift || true
BUDGET_MS="${VBNET_RG_BUDGET_MS:-250}"

if ! [[ "$BUDGET_MS" =~ ^[0-9]+$ ]] || [[ "$BUDGET_MS" -lt 1 ]]; then
  echo "FAIL: VBNET_RG_BUDGET_MS must be a positive integer (ms)"
  exit 1
fi

start_ns=$(date +%s%N)
set +e
bash "$HERE/vbnet-rg-gate.sh" "$ROOT" "$@" >"/tmp/vbnet-hotpath-rg.$$.out" 2>&1
rg_rc=$?
set -e
end_ns=$(date +%s%N)
elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
cat "/tmp/vbnet-hotpath-rg.$$.out"
rm -f "/tmp/vbnet-hotpath-rg.$$.out"

if [[ "$elapsed_ms" -gt "$BUDGET_MS" ]]; then
  echo "FAIL: vbnet-rg-gate wall ${elapsed_ms}ms exceeds budget ${BUDGET_MS}ms (VBNET_RG_BUDGET_MS)"
  exit 1
fi

if [[ "$rg_rc" -ne 0 ]]; then
  echo "FAIL: vbnet-rg-gate exit $rg_rc within budget ${elapsed_ms}ms/${BUDGET_MS}ms"
  exit "$rg_rc"
fi
echo "PASS vbnet-hotpath-gate ($ROOT, ${elapsed_ms}ms <= ${BUDGET_MS}ms)"
