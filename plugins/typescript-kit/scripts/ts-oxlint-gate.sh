#!/usr/bin/env bash
# Tier 0.5: require product oxlint config encoding the factory-wide TypeScript bar.
# Template alone is not adoption; product must ship .oxlintrc.json (or oxlint.json)
# with no-explicit-any, no-non-null-assertion, switch-exhaustiveness-check, and
# ban-ts-comment. When the oxlint binary (or npx) is available, also run it.
#
# Usage: bash scripts/ts-oxlint-gate.sh [root]
# Skip live run (config-only): TS_OXLINT_CONFIG_ONLY=1
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

cfg=""
if [[ -f .oxlintrc.json ]]; then
  cfg=.oxlintrc.json
elif [[ -f oxlint.json ]]; then
  cfg=oxlint.json
else
  echo "FAIL: missing .oxlintrc.json (copy typescript-kit/templates/oxlintrc.json)"
  exit 1
fi

required=(no-explicit-any no-non-null-assertion switch-exhaustiveness-check ban-ts-comment)
missing=0
for key in "${required[@]}"; do
  if ! grep -q "$key" "$cfg"; then
    echo "FAIL: $cfg missing factory rule key '$key'"
    missing=1
  fi
done
if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

run_oxlint=1
case "${TS_OXLINT_CONFIG_ONLY:-}" in
  1|true|TRUE|yes|YES) run_oxlint=0 ;;
esac

if [[ "$run_oxlint" -eq 1 ]]; then
  if command -v oxlint >/dev/null 2>&1; then
    oxlint -c "$cfg" .
  elif command -v npx >/dev/null 2>&1; then
    npx --yes oxlint@latest -c "$cfg" .
  else
    echo "FAIL: oxlint binary and npx both missing (set TS_OXLINT_CONFIG_ONLY=1 for config-only check)"
    exit 1
  fi
fi

echo "PASS ts-oxlint-gate ($ROOT, cfg=$cfg$([ "$run_oxlint" -eq 0 ] && echo ', config-only' || true))"
