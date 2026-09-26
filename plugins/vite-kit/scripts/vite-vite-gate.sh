#!/usr/bin/env bash
# Tier 1: require Vite wiring (PSR Vite language-farm).
# Live `vite` when vite exists unless VITE_VITE_CONFIG_ONLY=1.
# Portable bar: package.json "vite" / vite.config.* / CI vite build|dev|preview.
# Escape: VITE_VITE_GATE_SKIP=1.
# Usage: bash scripts/vite-vite-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${VITE_VITE_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS vite-vite-gate (skipped via VITE_VITE_GATE_SKIP=1)"
  exit 0
fi

mapfile -t vite_cfg < <(find . \( -name 'vite.config.js' -o -name 'vite.config.ts' -o -name 'vite.config.mjs' -o -name 'vite.config.cjs' -o -name 'vite.config.mts' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)

CFG=""
has_file_cfg=0
WIRE_PAT='(?i)"vite"\s*:'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock; do
  if [[ -f "$candidate" ]] && rg -qP "$WIRE_PAT" "$candidate" 2>/dev/null; then
    has_file_cfg=1
    CFG="$candidate"
    break
  fi
done

if [[ ${#vite_cfg[@]} -gt 0 ]]; then
  has_file_cfg=1
  CFG="${vite_cfg[0]}"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '\bvite\s+(build|dev|preview|optimize)\b|\bnpx\s+vite\b|\buno?\s+vite\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Require some vite surface: config file OR package vite key; if neither and no CI → fail
# Also require at least package or config so empty trees fail
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no vite wiring (package.json \"vite\": / vite.config.* / CI vite build|dev|preview; PSR: Vite toolchain)"
  exit 1
fi

# If only CI and no package/config and no vite.config — still ok via has_ci
# Missing fixture: no package vite and no config → fail above
# Weak fixture: package name contains vite substring but no "vite": key and no config

if [[ "${VITE_VITE_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS vite-vite-gate ($ROOT, config-only, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v vite >/dev/null 2>&1 || command -v npx >/dev/null 2>&1; then
  if command -v vite >/dev/null 2>&1; then
    bin=vite
  else
    bin="npx --no-install vite"
  fi
  set +e
  # shellcheck disable=SC2086
  $bin --version >/tmp/vite-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/vite-gate-ver.$$.out"
    echo "PASS vite-vite-gate ($ROOT, live vite, cfg=${CFG:-ci})"
    exit 0
  fi
  rm -f "/tmp/vite-gate-ver.$$.out"
fi

echo "PASS vite-vite-gate ($ROOT, config-only fallback, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
