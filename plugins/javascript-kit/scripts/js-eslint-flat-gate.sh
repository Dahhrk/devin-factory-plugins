#!/usr/bin/env bash
# Tier 1: require ESLint flat config (eslint.config.js|mjs|cjs) (PSR JS).
# Legacy .eslintrc* alone does NOT pass. Does not run eslint (host-dependent);
# proves flat config wiring exists. Escape: JS_ESLINT_FLAT_GATE_SKIP=1.
# Usage: bash scripts/js-eslint-flat-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${JS_ESLINT_FLAT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS js-eslint-flat-gate (skipped via JS_ESLINT_FLAT_GATE_SKIP=1)"
  exit 0
fi

found=0
for f in eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts; do
  if [[ -f "$f" ]]; then found=1; fi
done

# Nested package flat configs (monorepo root or package)
if [[ "$found" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name 'eslint.config.js' -o -name 'eslint.config.mjs' -o -name 'eslint.config.cjs' \) \
      -not -path '*/node_modules/*' 2>/dev/null | rg -q .; then
    found=1
  fi
fi

# package.json "eslintConfig" is legacy; do not count.
# CI that only runs eslint without flat config also does not count alone.
# Accept package.json type:module + eslint.config mention in scripts as soft? No — require file.

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no ESLint flat config (eslint.config.js|mjs|cjs) (PSR: ESLint; language-farm requires flat config; legacy .eslintrc alone fails)"
  exit 1
fi
echo "PASS js-eslint-flat-gate ($ROOT)"
