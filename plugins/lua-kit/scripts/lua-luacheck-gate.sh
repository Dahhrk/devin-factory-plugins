#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
if ! command -v luacheck >/dev/null 2>&1; then
  echo "FAIL: luacheck not found (install via luarocks install luacheck)"
  exit 1
fi
cd "$ROOT"
luacheck .
echo "PASS lua-luacheck-gate ($ROOT)"
