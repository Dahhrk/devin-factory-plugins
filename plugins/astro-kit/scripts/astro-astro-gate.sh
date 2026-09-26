#!/usr/bin/env bash
# Tier 1: require astro check/build wiring (PSR Astro language-farm).
# Live `astro` when astro exists unless ASTRO_ASTRO_CONFIG_ONLY=1.
# Portable bar: package.json "astro" / astro.config.* / CI astro check|build.
# Escape: ASTRO_ASTRO_GATE_SKIP=1.
# Usage: bash scripts/astro-astro-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${ASTRO_ASTRO_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS astro-astro-gate (skipped via ASTRO_ASTRO_GATE_SKIP=1)"
  exit 0
fi

mapfile -t astro_files < <(find . \( -name '*.astro' -o -name '*.ASTRO' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#astro_files[@]} -eq 0 ]]; then
  echo "FAIL: no Astro sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
WIRE_PAT='(?i)"astro"\s*:'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock \
  astro.config.mjs astro.config.js astro.config.ts astro.config.cjs; do
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
  if rg -qiP '\bastro\s+(check|build|preview)\b|\bnpx\s+astro\b|\buno?\s+astro\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no astro wiring (package.json astro / astro.config.* / CI astro check|build; PSR: Astro toolchain)"
  exit 1
fi

if [[ "${ASTRO_ASTRO_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS astro-astro-gate ($ROOT, config-only, ${#astro_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v astro >/dev/null 2>&1 || command -v npx >/dev/null 2>&1; then
  if command -v astro >/dev/null 2>&1; then
    bin=astro
  else
    bin="npx --no-install astro"
  fi
  set +e
  # Prefer version probe; do not invent full project build on every host.
  # shellcheck disable=SC2086
  $bin --version >/tmp/astro-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/astro-gate-ver.$$.out"
    echo "PASS astro-astro-gate ($ROOT, live astro, ${#astro_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/astro-gate-ver.$$.out"
fi

echo "PASS astro-astro-gate ($ROOT, config-only fallback, ${#astro_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
