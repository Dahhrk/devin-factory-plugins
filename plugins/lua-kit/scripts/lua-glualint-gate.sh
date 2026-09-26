#!/usr/bin/env bash
# Tier 2: glualint (FPtje/GLuaFixer). Required formatter/linter bar (PSR Lua ch.4).
set -euo pipefail
ROOT="${1:-.}"
if ! command -v glualint >/dev/null 2>&1; then
  echo "FAIL: glualint not found (pin FPtje/GLuaFixer release; see templates/github-workflows/lua-gates.yml)"
  exit 1
fi
cd "$ROOT"
if [ ! -f glualint.json ] && [ ! -f .glualint.json ]; then
  echo "FAIL: missing glualint.json (copy from lua-kit/templates/glualint.json)"
  exit 1
fi
glualint lint .
echo "PASS lua-glualint-gate ($ROOT)"
