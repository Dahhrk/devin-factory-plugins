#!/usr/bin/env bash
# Tier 0.5: require product oxlint config encoding the factory-wide TypeScript bar.
# Template alone is not adoption; product must ship .oxlintrc.json (or oxlint.json)
# with no-explicit-any, no-non-null-assertion, switch-exhaustiveness-check,
# ban-ts-comment, no-floating-promises, no-misused-promises, and options.typeAware.
# Live runs are type-aware: pin oxlint + oxlint-tsgolint (never floating-latest).
#
# Pin: prefer TS_OXLINT_BIN, PATH, then node_modules/.bin, then
#   npx -p oxlint@$TS_OXLINT_VERSION -p oxlint-tsgolint@$TS_OXLINT_TSGOLINT_VERSION oxlint
# Offline: TS_OXLINT_OFFLINE=1 refuses npx (requires local oxlint + tsgolint).
#
# Usage: bash scripts/ts-oxlint-gate.sh [root]
# Skip live run (config-only): TS_OXLINT_CONFIG_ONLY=1
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

# Pinned releases for live runs (bump deliberately with kit encode).
TS_OXLINT_VERSION="${TS_OXLINT_VERSION:-1.85.0}"
TS_OXLINT_TSGOLINT_VERSION="${TS_OXLINT_TSGOLINT_VERSION:-7.0.2003}"

cfg=""
if [[ -f .oxlintrc.json ]]; then
  cfg=.oxlintrc.json
elif [[ -f oxlint.json ]]; then
  cfg=oxlint.json
else
  echo "FAIL: missing .oxlintrc.json (copy typescript-kit/templates/oxlintrc.json)"
  exit 1
fi

required=(no-explicit-any no-non-null-assertion switch-exhaustiveness-check ban-ts-comment no-floating-promises no-misused-promises)
missing=0
for key in "${required[@]}"; do
  if ! grep -q "$key" "$cfg"; then
    echo "FAIL: $cfg missing factory rule key '$key'"
    missing=1
  fi
done
if ! grep -q 'typeAware' "$cfg"; then
  echo "FAIL: $cfg missing options.typeAware (type-aware floating/misused promises require oxlint-tsgolint)"
  missing=1
fi
if [[ "$missing" -ne 0 ]]; then
  exit 1
fi

run_oxlint=1
case "${TS_OXLINT_CONFIG_ONLY:-}" in
  1|true|TRUE|yes|YES) run_oxlint=0 ;;
esac

offline=0
case "${TS_OXLINT_OFFLINE:-}" in
  1|true|TRUE|yes|YES) offline=1 ;;
esac

has_tsgolint_near() {
  local dir="$1"
  [[ -x "$dir/node_modules/.bin/tsgolint" ]] \
    || [[ -d "$dir/node_modules/oxlint-tsgolint" ]]
}

resolve_oxlint() {
  # Prints: "<mode> <command...>" where mode is bin|npx
  if [[ -n "${TS_OXLINT_BIN:-}" ]]; then
    if [[ -x "$TS_OXLINT_BIN" ]] || command -v "$TS_OXLINT_BIN" >/dev/null 2>&1; then
      echo "bin $TS_OXLINT_BIN"
      return 0
    fi
    echo "FAIL: TS_OXLINT_BIN='$TS_OXLINT_BIN' not executable" >&2
    return 1
  fi
  if command -v oxlint >/dev/null 2>&1; then
    echo "bin $(command -v oxlint)"
    return 0
  fi
  if [[ -x ./node_modules/.bin/oxlint ]]; then
    echo "bin ./node_modules/.bin/oxlint"
    return 0
  fi
  if [[ -x "$ROOT/node_modules/.bin/oxlint" ]]; then
    echo "bin $ROOT/node_modules/.bin/oxlint"
    return 0
  fi
  if [[ "$offline" -eq 1 ]]; then
    echo "FAIL: offline oxlint required (TS_OXLINT_OFFLINE=1) but no local binary (set TS_OXLINT_BIN or install oxlint@$TS_OXLINT_VERSION + oxlint-tsgolint@$TS_OXLINT_TSGOLINT_VERSION into PATH / node_modules)" >&2
    return 1
  fi
  if command -v npx >/dev/null 2>&1; then
    echo "npx npx --yes -p oxlint@${TS_OXLINT_VERSION} -p oxlint-tsgolint@${TS_OXLINT_TSGOLINT_VERSION} oxlint"
    return 0
  fi
  echo "FAIL: oxlint binary and npx both missing (set TS_OXLINT_CONFIG_ONLY=1 for config-only, or install oxlint@$TS_OXLINT_VERSION + oxlint-tsgolint@$TS_OXLINT_TSGOLINT_VERSION)" >&2
  return 1
}

ensure_tsgolint_for_bin() {
  # Type-aware live needs tsgolint beside oxlint or on PATH (npx path bundles both).
  local mode="$1"
  if [[ "$mode" == "npx" ]]; then
    return 0
  fi
  if [[ -n "${TS_OXLINT_TSGOLINT_BIN:-}" ]]; then
    if [[ -x "$TS_OXLINT_TSGOLINT_BIN" ]] || command -v "$TS_OXLINT_TSGOLINT_BIN" >/dev/null 2>&1; then
      return 0
    fi
    echo "FAIL: TS_OXLINT_TSGOLINT_BIN='$TS_OXLINT_TSGOLINT_BIN' not executable" >&2
    return 1
  fi
  if command -v tsgolint >/dev/null 2>&1; then
    return 0
  fi
  if has_tsgolint_near "." || has_tsgolint_near "$ROOT"; then
    return 0
  fi
  echo "FAIL: type-aware oxlint requires oxlint-tsgolint@$TS_OXLINT_TSGOLINT_VERSION (install beside oxlint, set TS_OXLINT_TSGOLINT_BIN, or allow npx dual-package resolve)" >&2
  return 1
}

if [[ "$run_oxlint" -eq 1 ]]; then
  resolved="$(resolve_oxlint)" || exit 1
  mode="${resolved%% *}"
  cmd="${resolved#* }"
  ensure_tsgolint_for_bin "$mode" || exit 1
  # shellcheck disable=SC2086
  $cmd --type-aware -c "$cfg" .
  echo "PASS ts-oxlint-gate ($ROOT, cfg=$cfg, live=$mode, typeAware=1, pin=$TS_OXLINT_VERSION, tsgolint=$TS_OXLINT_TSGOLINT_VERSION)"
else
  echo "PASS ts-oxlint-gate ($ROOT, cfg=$cfg, config-only, typeAware keys ok, pin=$TS_OXLINT_VERSION, tsgolint=$TS_OXLINT_TSGOLINT_VERSION)"
fi
