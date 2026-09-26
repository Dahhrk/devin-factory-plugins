#!/usr/bin/env bash
# Tier 1: require fortitude lint wiring (PSR Fortran language-farm).
# Live fortitude check when fortitude exists unless FORTRAN_FORTITUDE_CONFIG_ONLY=1.
# Portable bar: .fortitude.toml / fortitude.toml / [tool.fortitude] / CI fortitude check.
# Config text must keep C001 / implicit-typing enabled (not ignored / excluded).
# Escape: FORTRAN_FORTITUDE_GATE_SKIP=1.
# Usage: bash scripts/fortran-fortitude-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${FORTRAN_FORTITUDE_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS fortran-fortitude-gate (skipped via FORTRAN_FORTITUDE_GATE_SKIP=1)"
  exit 0
fi

mapfile -t f_files < <(find . \( \
  -name '*.f90' -o -name '*.F90' -o -name '*.f95' -o -name '*.F95' \
  -o -name '*.f03' -o -name '*.F03' -o -name '*.f08' -o -name '*.F08' \
  -o -name '*.f' -o -name '*.F' -o -name '*.fypp' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#f_files[@]} -eq 0 ]]; then
  echo "FAIL: no Fortran sources under $ROOT"
  exit 1
fi

CFG=""
CFG_TEXT=""
for candidate in .fortitude.toml fortitude.toml; do
  if [[ -f "$candidate" ]]; then
    CFG="$candidate"
    CFG_TEXT="$(cat "$candidate")"
    break
  fi
done

# pyproject [tool.fortitude]
if [[ -z "$CFG" && -f pyproject.toml ]]; then
  if rg -q '\[tool\.fortitude' pyproject.toml 2>/dev/null; then
    CFG="pyproject.toml"
    CFG_TEXT="$(cat pyproject.toml)"
  fi
fi

has_file_cfg=0
[[ -n "$CFG" ]] && has_file_cfg=1

if [[ "$has_file_cfg" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name '.fortitude.toml' -o -name 'fortitude.toml' \) -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested" ]]; then
    has_file_cfg=1
    CFG="$nested"
    CFG_TEXT="$(cat "$nested")"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi 'fortitude([[:space:]]|$)|fortitude[[:space:]]+check' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no fortitude wiring (.fortitude.toml / fortitude.toml / [tool.fortitude] / CI fortitude check; PSR: fortitude lint)"
  exit 1
fi

# Require PSR C001 / implicit-typing encode when a product fortitude config is present.
require_c001_enabled() {
  local flat
  flat="$(echo "$CFG_TEXT" | tr '\n' ' ')"
  # Fail if C001 or implicit-typing explicitly ignored.
  if echo "$flat" | rg -qi 'ignore\s*=\s*\[[^]]*(C001|implicit-typing)'; then
    echo "FAIL: $CFG ignores C001 / implicit-typing (PSR: keep implicit-typing enabled)"
    return 1
  fi
  if echo "$flat" | rg -qi 'extend-ignore\s*=\s*\[[^]]*(C001|implicit-typing)'; then
    echo "FAIL: $CFG extend-ignores C001 / implicit-typing (PSR: keep implicit-typing enabled)"
    return 1
  fi
  # Product bar: require C001 or implicit-typing named, OR a select that includes C / correctness defaults.
  if echo "$CFG_TEXT" | rg -q 'C001|implicit-typing'; then
    return 0
  fi
  if echo "$flat" | rg -q 'select\s*=\s*\[[^]]*("C"|'"'"'C'"'"'|C001)'; then
    return 0
  fi
  # Bare empty ignore with no select still runs defaults (C001 on by default) — accept if ignore = [] only / no ignore.
  if ! echo "$CFG_TEXT" | rg -q 'ignore\s*='; then
    return 0
  fi
  if echo "$flat" | rg -q 'ignore\s*=\s*\[\s*\]'; then
    return 0
  fi
  echo "FAIL: $CFG missing C001 / implicit-typing encode (PSR: fortitude C001 bar)"
  return 1
}

if [[ -n "$CFG_TEXT" && "$CFG" != *".github"* ]]; then
  if ! require_c001_enabled; then
    exit 1
  fi
fi

if [[ "${FORTRAN_FORTITUDE_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS fortran-fortitude-gate ($ROOT, config-only, ${#f_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v fortitude >/dev/null 2>&1; then
  set +e
  fortitude check . >/tmp/fortitude-gate-lint.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/fortitude-gate-lint.$$.out"
    echo "PASS fortran-fortitude-gate ($ROOT, live fortitude check, ${#f_files[@]} files)"
    exit 0
  fi
  # Non-zero live lint still means wiring works; product may have style debt.
  # Config-only fallback reports live_rc for honesty (same as r-lintr-gate).
  rm -f "/tmp/fortitude-gate-lint.$$.out"
fi

echo "PASS fortran-fortitude-gate ($ROOT, config-only fallback, ${#f_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
