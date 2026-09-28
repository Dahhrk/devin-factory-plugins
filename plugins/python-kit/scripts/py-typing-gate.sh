#!/usr/bin/env bash
# Tier 1: require mypy or Pyright config in strict mode (PSR: use mypy or Pyright when useful).
# Usage: bash scripts/py-typing-gate.sh [root]
# Escape: PY_TYPING_GATE_SKIP=1 for tiny scripts that intentionally skip typing.
# Config-level only (no live mypy/pyright binary). Accepts mypy strict=true or
# pyright typeCheckingMode=strict from at least one configured checker.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${PY_TYPING_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS py-typing-gate (skipped via PY_TYPING_GATE_SKIP=1)"
  exit 0
fi

has_config=0
strict=0

check_mypy_file() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  has_config=1
  if rg -q '^[[:space:]]*strict[[:space:]]*=[[:space:]]*(true|True)[[:space:]]*$' "$f" 2>/dev/null; then
    strict=1
  fi
  return 0
}

check_pyright_json() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  has_config=1
  if rg -q '"typeCheckingMode"[[:space:]]*:[[:space:]]*"strict"' "$f" 2>/dev/null; then
    strict=1
  fi
  return 0
}

check_mypy_file mypy.ini || true
check_mypy_file .mypy.ini || true
check_pyright_json pyrightconfig.json || true

if [[ -f pyproject.toml ]]; then
  if rg -q '^\[tool\.mypy\]|^\[tool\.pyright\]' pyproject.toml 2>/dev/null; then
    has_config=1
  fi
  # mypy strict in pyproject (tool.mypy table or inline)
  if rg -q '^[[:space:]]*strict[[:space:]]*=[[:space:]]*(true|True)[[:space:]]*$' pyproject.toml 2>/dev/null; then
    # Prefer only counting when under mypy, but a bare strict=true next to [tool.mypy] is the factory bar.
    # Also accept if [tool.mypy] exists and strict=true appears anywhere in file (flask/requests shape).
    if rg -q '^\[tool\.mypy\]' pyproject.toml 2>/dev/null; then
      strict=1
    fi
  fi
  # pyright typeCheckingMode = "strict" in toml
  if rg -q '^[[:space:]]*typeCheckingMode[[:space:]]*=[[:space:]]*"strict"' pyproject.toml 2>/dev/null; then
    if rg -q '^\[tool\.pyright\]' pyproject.toml 2>/dev/null; then
      strict=1
    fi
  fi
fi

if [[ "$has_config" -eq 0 ]]; then
  echo "FAIL: no mypy or Pyright config (mypy.ini / pyrightconfig.json / [tool.mypy]|[tool.pyright] in pyproject.toml)"
  exit 1
fi

if [[ "$strict" -eq 0 ]]; then
  echo "FAIL: typing config present but not strict (set mypy strict = true or pyright typeCheckingMode = \"strict\"; or PY_TYPING_GATE_SKIP=1)"
  exit 1
fi

echo "PASS py-typing-gate ($ROOT, strict)"
