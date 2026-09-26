#!/usr/bin/env bash
# Tier 1: require mypy or Pyright config (PSR: use mypy or Pyright when useful).
# Usage: bash scripts/py-typing-gate.sh [root]
# Escape: PY_TYPING_GATE_SKIP=1 for tiny scripts that intentionally skip typing.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${PY_TYPING_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS py-typing-gate (skipped via PY_TYPING_GATE_SKIP=1)"
  exit 0
fi

found=0
[[ -f mypy.ini ]] && found=1
[[ -f .mypy.ini ]] && found=1
[[ -f pyrightconfig.json ]] && found=1
if [[ -f pyproject.toml ]]; then
  if rg -q '^\[tool\.mypy\]|^\[tool\.pyright\]' pyproject.toml 2>/dev/null; then found=1; fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no mypy or Pyright config (mypy.ini / pyrightconfig.json / [tool.mypy]|[tool.pyright] in pyproject.toml)"
  exit 1
fi
echo "PASS py-typing-gate ($ROOT)"
