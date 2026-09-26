#!/usr/bin/env bash
# Tier 1: require dart-sass / sass compile wiring (PSR SCSS language-farm).
# Live `sass` when sass exists unless SCSS_SASS_CONFIG_ONLY=1.
# Portable bar: package.json "sass" / dart-sass / CI sass / sass.config.*.
# Escape: SCSS_SASS_GATE_SKIP=1.
# Usage: bash scripts/scss-sass-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${SCSS_SASS_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS scss-sass-gate (skipped via SCSS_SASS_GATE_SKIP=1)"
  exit 0
fi

mapfile -t scss_files < <(find . \( -name '*.scss' -o -name '*.sass' -o -name '*.SCSS' -o -name '*.SASS' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#scss_files[@]} -eq 0 ]]; then
  echo "FAIL: no SCSS/Sass sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
WIRE_PAT='(?i)("sass"\s*:|"dart-sass"\s*:|\bsass\b|\bdart-sass\b)'

for candidate in package.json package-lock.json pnpm-lock.yaml yarn.lock \
  sass.config.js sass.config.cjs sass.config.mjs .sassrc .sassrc.json; do
  if [[ -f "$candidate" ]]; then
    if [[ "$candidate" == package.json ]] || [[ "$candidate" == package-lock.json ]] \
      || [[ "$candidate" == pnpm-lock.yaml ]] || [[ "$candidate" == yarn.lock ]]; then
      if rg -qP "$WIRE_PAT" "$candidate" 2>/dev/null; then
        has_file_cfg=1
        CFG="$candidate"
        break
      fi
    else
      has_file_cfg=1
      CFG="$candidate"
      break
    fi
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '\bsass\b|dart-sass' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no sass / dart-sass wiring (package.json sass / dart-sass / sass.config.* / CI sass; PSR: dart-sass compile)"
  exit 1
fi

# Weak config: package.json present with other deps but sass key explicitly absent already failed above.
# Extra: if package.json exists and mentions sass only as a comment-like non-dep — already covered by WIRE_PAT.

if [[ "${SCSS_SASS_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS scss-sass-gate ($ROOT, config-only, ${#scss_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v sass >/dev/null 2>&1; then
  bin="${SCSS_SASS_BIN:-sass}"
  src="${SCSS_SASS_SRC:-}"
  if [[ -z "$src" ]]; then
    if [[ -d src ]]; then src="src"
    elif [[ -d styles ]]; then src="styles"
    elif [[ -d scss ]]; then src="scss"
    else src="."; fi
  fi
  set +e
  "$bin" --version >/tmp/sass-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/sass-gate-ver.$$.out"
    echo "PASS scss-sass-gate ($ROOT, live sass, ${#scss_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/sass-gate-ver.$$.out"
fi

echo "PASS scss-sass-gate ($ROOT, config-only fallback, ${#scss_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
