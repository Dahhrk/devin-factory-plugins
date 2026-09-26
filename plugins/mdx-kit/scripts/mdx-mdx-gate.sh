#!/usr/bin/env bash
# Tier 1: require @mdx-js / MDX toolchain wiring (PSR MDX language-farm).
# Live import when resolvable unless MDX_MDX_CONFIG_ONLY=1.
# Portable bar: package.json @mdx-js/* / @next/mdx / mdx config / CI mdx.
# Escape: MDX_MDX_GATE_SKIP=1.
# Usage: bash scripts/mdx-mdx-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${MDX_MDX_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS mdx-mdx-gate (skipped via MDX_MDX_GATE_SKIP=1)"
  exit 0
fi

mapfile -t mdx_files < <(find . \( -name '*.mdx' -o -name '*.MDX' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#mdx_files[@]} -eq 0 ]]; then
  echo "FAIL: no MDX sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require a real MDX toolchain key (not bare substring "mdx" in a package name).
WIRE_PAT='(?i)"(@mdx-js/(mdx|rollup|loader|esbuild|node-loader|react|preact|vue)|@next/mdx)"\s*:'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock \
  next.config.js next.config.mjs next.config.ts \
  mdx.config.js mdx.config.mjs mdx-components.js mdx-components.tsx mdx-components.jsx; do
  if [[ -f "$candidate" ]]; then
    case "$candidate" in
      package.json|package-lock.json|pnpm-lock.yaml|yarn.lock)
        if rg -qP "$WIRE_PAT" "$candidate" 2>/dev/null; then
          has_file_cfg=1
          CFG="$candidate"
          break
        fi
        ;;
      *)
        has_file_cfg=1
        CFG="$candidate"
        break
        ;;
    esac
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '@mdx-js/|@next/mdx|\bmdxlint\b|\beslint-mdx\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no mdx wiring (package.json @mdx-js/* / @next/mdx / mdx config / CI; PSR: MDX toolchain)"
  exit 1
fi

if [[ "${MDX_MDX_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS mdx-mdx-gate ($ROOT, config-only, ${#mdx_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v node >/dev/null 2>&1; then
  set +e
  node --input-type=module -e "import('@mdx-js/mdx').then(()=>process.exit(0)).catch(()=>process.exit(1))" \
    >/tmp/mdx-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/mdx-gate-ver.$$.out"
    echo "PASS mdx-mdx-gate ($ROOT, live @mdx-js/mdx, ${#mdx_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/mdx-gate-ver.$$.out"
fi

echo "PASS mdx-mdx-gate ($ROOT, config-only fallback, ${#mdx_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
