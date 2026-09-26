#!/usr/bin/env bash
# Tier 1: require tailwindcss toolchain wiring (PSR Tailwind language-farm).
# Live require/import when resolvable unless TAILWIND_TAILWIND_CONFIG_ONLY=1.
# Portable bar: package.json "tailwindcss": / tailwind.config.* /
# @import "tailwindcss" / @tailwind / CI.
# Escape: TAILWIND_TAILWIND_GATE_SKIP=1.
# Usage: bash scripts/tailwind-tailwind-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${TAILWIND_TAILWIND_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS tailwind-tailwind-gate (skipped via TAILWIND_TAILWIND_GATE_SKIP=1)"
  exit 0
fi

mapfile -t tw_files < <(find . \( \
  -name '*.css' -o -name '*.CSS' -o -name '*.html' -o -name '*.HTML' \
  -o -name '*.jsx' -o -name '*.tsx' -o -name '*.vue' -o -name '*.svelte' \
  -o -name '*.astro' -o -name 'tailwind.config.js' -o -name 'tailwind.config.cjs' \
  -o -name 'tailwind.config.mjs' -o -name 'tailwind.config.ts' \
\) -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#tw_files[@]} -eq 0 ]]; then
  echo "FAIL: no Tailwind-related sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require a real tailwindcss toolchain key (not bare substring in a package name).
WIRE_PAT='(?i)"tailwindcss"\s*:'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock \
  tailwind.config.js tailwind.config.cjs tailwind.config.mjs tailwind.config.ts; do
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

# CSS entry import / @tailwind directive counts as wiring when package/config absent.
if [[ "$has_file_cfg" -eq 0 ]]; then
  if rg -qP '(?i)@import\s+["'\'']tailwindcss["'\'']|@tailwind\s+(base|components|utilities)\b' \
    --glob '*.css' --glob '*.CSS' . 2>/dev/null; then
    has_file_cfg=1
    CFG="css-entry"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])tailwind(css)?([^\w-]|$)|@tailwindcss/' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no tailwindcss wiring (package.json \"tailwindcss\": / tailwind.config.* / @import \"tailwindcss\" / CI; PSR: Tailwind toolchain)"
  exit 1
fi

if [[ "${TAILWIND_TAILWIND_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS tailwind-tailwind-gate ($ROOT, config-only, ${#tw_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v node >/dev/null 2>&1; then
  set +e
  node --input-type=module -e "import('tailwindcss').then(()=>process.exit(0)).catch(()=>process.exit(1))" \
    >/tmp/tailwind-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/tailwind-gate-ver.$$.out"
    echo "PASS tailwind-tailwind-gate ($ROOT, live tailwindcss, ${#tw_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/tailwind-gate-ver.$$.out"
fi

echo "PASS tailwind-tailwind-gate ($ROOT, config-only fallback, ${#tw_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
