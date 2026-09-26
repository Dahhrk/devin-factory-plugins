#!/usr/bin/env bash
# Tier 0.5: wall-clock budget for sh-rg-gate (kit hot-path EXIT).
# Default budget 250ms (headroom for loaded CI). Override: SH_RG_BUDGET_MS.
# Usage: bash scripts/sh-hotpath-gate.sh [root] [path ...]
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-.}"
shift || true
BUDGET_MS="${SH_RG_BUDGET_MS:-250}"

if ! [[ "$BUDGET_MS" =~ ^[0-9]+$ ]] || [[ "$BUDGET_MS" -lt 1 ]]; then
  echo "FAIL: SH_RG_BUDGET_MS must be a positive integer (ms)"
  exit 1
fi

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT
start_ns=$(date +%s%N)
set +e
bash "$HERE/sh-rg-gate.sh" "$ROOT" "$@" >"$OUT" 2>&1
rg_rc=$?
set -e
end_ns=$(date +%s%N)
elapsed_ms=$(((end_ns - start_ns) / 1000000))
cat "$OUT"

if [[ "$elapsed_ms" -gt "$BUDGET_MS" ]]; then
  echo "FAIL: sh-rg-gate wall ${elapsed_ms}ms exceeds budget ${BUDGET_MS}ms (SH_RG_BUDGET_MS)"
  exit 1
fi

if [[ "$rg_rc" -ne 0 ]]; then
  echo "FAIL: sh-rg-gate exit $rg_rc within budget ${elapsed_ms}ms/${BUDGET_MS}ms"
  exit "$rg_rc"
fi
echo "PASS sh-hotpath-gate ($ROOT, ${elapsed_ms}ms <= ${BUDGET_MS}ms)"
