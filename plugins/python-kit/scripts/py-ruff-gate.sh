#!/usr/bin/env bash
# Tier 0.5: require Ruff config with E/F/B (PSR: one formatter + lint with Ruff).
# Live `ruff check` when ruff is on PATH unless PY_RUFF_CONFIG_ONLY=1.
# Usage: bash scripts/py-ruff-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

CFG=""
if [[ -f ruff.toml ]]; then CFG="ruff.toml"
elif [[ -f .ruff.toml ]]; then CFG=".ruff.toml"
elif [[ -f pyproject.toml ]] && rg -q '^\[tool\.ruff' pyproject.toml 2>/dev/null; then CFG="pyproject.toml"
fi

if [[ -z "$CFG" ]]; then
  echo "FAIL: no Ruff config (ruff.toml / .ruff.toml / [tool.ruff] in pyproject.toml); copy python-kit/templates/ruff.toml"
  exit 1
fi

# Require select includes E, F, B (pycodestyle/pyflakes/bugbear) somewhere in config text
fail=0
for key in E F B; do
  if ! rg -q -- "\"$key\"|'$key'|,[[:space:]]*$key[[:space:]]*,|[[:space:]]*$key[[:space:]]*$|select[[:space:]]*=[[:space:]]*.*$key" "$CFG"; then
    # Also accept flake8-bugbear style "B" inside a list on the file
    if ! rg -q "\b$key\b" "$CFG"; then
      echo "FAIL: $CFG missing Ruff select $key (PSR: lint with Ruff E/F/B bar)"
      fail=1
    fi
  fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi

if [[ "${PY_RUFF_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS py-ruff-gate ($ROOT/$CFG, config-only)"
  exit 0
fi

if ! command -v ruff >/dev/null 2>&1; then
  echo "FAIL: ruff not on PATH (install ruff, or set PY_RUFF_CONFIG_ONLY=1 / PY_RUFF_BIN)"
  exit 1
fi

RUFF_BIN="${PY_RUFF_BIN:-ruff}"
SRC="src"
[[ -d src ]] || SRC="."
"$RUFF_BIN" check "$SRC"
echo "PASS py-ruff-gate ($ROOT/$CFG, live)"
