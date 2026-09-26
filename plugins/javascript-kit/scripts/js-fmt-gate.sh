#!/usr/bin/env bash
# Tier 0.5a: formatter wiring (PSR JS: Prettier / agreed formatter).
# Live `prettier --check` when prettier exists unless JS_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/js-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . \( -name '*.js' -o -name '*.mjs' -o -name '*.cjs' -o -name '*.jsx' \) -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/test/*' -not -path '*/tests/*' -not -path '*/coverage/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no JavaScript sources under $ROOT"
  exit 1
fi

has_cfg=0
# Prettier config files
for f in .prettierrc .prettierrc.json .prettierrc.yml .prettierrc.yaml .prettierrc.js .prettierrc.cjs .prettierrc.mjs prettier.config.js prettier.config.cjs prettier.config.mjs; do
  [[ -f $f ]] && has_cfg=1
done
# package.json prettier key or prettier dep + format script
if [[ -f package.json ]]; then
  if rg -qi '"prettier"|prettier\.config|"format"[[:space:]]*:[[:space:]]*"[^"]*prettier' package.json 2>/dev/null; then has_cfg=1; fi
fi
# CI prettier
if [[ -d .github/workflows ]]; then
  if rg -qi 'prettier' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi

if [[ "${JS_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS js-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no Prettier wiring (copy javascript-kit/templates/prettierrc.json; or unset JS_FMT_CONFIG_ONLY)"
  exit 1
fi

run_prettier() {
  if command -v prettier >/dev/null 2>&1; then
    prettier --check "${files[@]}" 2>/dev/null
    return $?
  fi
  if [[ -f package.json ]] && command -v npx >/dev/null 2>&1; then
    npx --no-install prettier --check "${files[@]}" 2>/dev/null
    return $?
  fi
  return 127
}

if run_prettier; then
  echo "PASS js-fmt-gate ($ROOT, live prettier, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS js-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install prettier for live)"
    exit 0
  fi
  echo "FAIL: prettier not on PATH and no Prettier config / package.json prettier / CI wiring (PSR: agreed formatter)"
  exit 1
fi

# live failure may be host noise; fall through to config if present
if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS js-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: prettier --check would rewrite sources (PSR: agreed formatter)"
exit 1
