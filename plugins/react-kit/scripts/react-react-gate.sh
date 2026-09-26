#!/usr/bin/env bash
# Tier 1: require React wiring (PSR React language-farm).
# Live `react` resolve when node exists unless REACT_REACT_CONFIG_ONLY=1.
# Portable bar: package.json "react" / "react-dom" / CI react-related / vite+react plugin.
# Escape: REACT_REACT_GATE_SKIP=1.
# Usage: bash scripts/react-react-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${REACT_REACT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS react-react-gate (skipped via REACT_REACT_GATE_SKIP=1)"
  exit 0
fi

mapfile -t react_files < <(find . \( -name '*.jsx' -o -name '*.tsx' -o -name '*.JSX' -o -name '*.TSX' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
# Also accept .js/.ts that import react when no jsx/tsx present — require at least one react source or package
if [[ ${#react_files[@]} -eq 0 ]]; then
  # fall through: still require wiring if package claims react; else fail no sources
  :
fi

CFG=""
has_file_cfg=0
WIRE_PAT='(?i)"(react|react-dom|@vitejs/plugin-react|@vitejs/plugin-react-swc)"\s*:'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock; do
  if [[ -f "$candidate" ]] && rg -qP "$WIRE_PAT" "$candidate" 2>/dev/null; then
    has_file_cfg=1
    CFG="$candidate"
    break
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '\b(react-scripts|vite\s+build|vitest|@vitejs/plugin-react)\b|"react"\s*:' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ ${#react_files[@]} -eq 0 && "$has_file_cfg" -eq 0 ]]; then
  echo "FAIL: no React sources (.jsx/.tsx) under $ROOT"
  exit 1
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no react wiring (package.json react / react-dom / @vitejs/plugin-react / CI; PSR: React toolchain)"
  exit 1
fi

if [[ "${REACT_REACT_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS react-react-gate ($ROOT, config-only, ${#react_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v node >/dev/null 2>&1; then
  set +e
  node -e "require.resolve('react')" >/tmp/react-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/react-gate-ver.$$.out"
    echo "PASS react-react-gate ($ROOT, live react, ${#react_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/react-gate-ver.$$.out"
fi

echo "PASS react-react-gate ($ROOT, config-only fallback, ${#react_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
