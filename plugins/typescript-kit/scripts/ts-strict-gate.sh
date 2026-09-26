#!/usr/bin/env bash
# Tier 0.5: require strict + noImplicitAny on the app tsconfig, and a typecheck script.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0

if [[ ! -f package.json ]]; then
  echo "FAIL: package.json missing"
  exit 1
fi

if ! grep -Eq '"typecheck"\s*:' package.json; then
  echo "FAIL: package.json missing typecheck script (PSR: type-check in CI)"
  fail=1
fi

APP_TSCONFIG=""
for candidate in tsconfig.app.json tsconfig.json; do
  if [[ -f "$candidate" ]]; then
    APP_TSCONFIG="$candidate"
    break
  fi
done

if [[ -z "$APP_TSCONFIG" ]]; then
  echo "FAIL: no tsconfig.app.json or tsconfig.json"
  exit 1
fi

# Prefer tsconfig.app.json content when present (Vite project references).
check_flag() {
  local file="$1" key="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "\"$key\"\s*:\s*true" "$file"
  else
    grep -Eq "\"$key\"[[:space:]]*:[[:space:]]*true" "$file"
  fi
}

PRIMARY="$APP_TSCONFIG"
# If root tsconfig is references-only, require flags on tsconfig.app.json
if [[ -f tsconfig.app.json ]]; then
  PRIMARY="tsconfig.app.json"
fi

if ! check_flag "$PRIMARY" "strict"; then
  echo "FAIL: $PRIMARY missing \"strict\": true (PSR: enable strict checking)"
  fail=1
fi
if ! check_flag "$PRIMARY" "noImplicitAny"; then
  # strict implies noImplicitAny, but require the explicit flag when present files set lint opts
  if ! check_flag "$PRIMARY" "strict"; then
    echo "FAIL: $PRIMARY missing noImplicitAny (and strict not true)"
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-strict-gate ($ROOT, $PRIMARY)"
