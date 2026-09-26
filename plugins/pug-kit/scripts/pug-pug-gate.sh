#!/usr/bin/env bash
# Tier 1: require pug toolchain wiring (PSR Pug language-farm).
# Live require/import when resolvable unless PUG_PUG_CONFIG_ONLY=1.
# Portable bar: package.json "pug": / pug config / CI pug.
# Escape: PUG_PUG_GATE_SKIP=1.
# Usage: bash scripts/pug-pug-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${PUG_PUG_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS pug-pug-gate (skipped via PUG_PUG_GATE_SKIP=1)"
  exit 0
fi

mapfile -t pug_files < <(find . \( -name '*.pug' -o -name '*.Pug' -o -name '*.jade' -o -name '*.Jade' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#pug_files[@]} -eq 0 ]]; then
  echo "FAIL: no Pug sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require a real pug toolchain key (not bare substring "pug" in a package name).
WIRE_PAT='(?i)"pug"\s*:'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock \
  .pugrc .pugrc.js .pugrc.json .pugrc.cjs pug.config.js pug.config.cjs pug.config.mjs; do
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
  if rg -qiP '(^|[^\w-])pug([^\w-]|$)|pug-lint|\bpug\s+(compile|render)' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no pug wiring (package.json \"pug\": / pug config / CI; PSR: Pug toolchain)"
  exit 1
fi

if [[ "${PUG_PUG_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS pug-pug-gate ($ROOT, config-only, ${#pug_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v node >/dev/null 2>&1; then
  set +e
  node --input-type=module -e "import('pug').then(()=>process.exit(0)).catch(()=>process.exit(1))" \
    >/tmp/pug-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/pug-gate-ver.$$.out"
    echo "PASS pug-pug-gate ($ROOT, live pug, ${#pug_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/pug-gate-ver.$$.out"
fi

echo "PASS pug-pug-gate ($ROOT, config-only fallback, ${#pug_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
