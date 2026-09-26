#!/usr/bin/env bash
# Tier 0.5: require strict (+ implied noImplicitAny) on the app tsconfig, and a
# typecheck script. Walks tsconfig "extends" so base/build configs count
# (eslint / tRPC-shaped trees).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0

if [[ ! -f package.json ]]; then
  echo "FAIL: package.json missing"
  exit 1
fi

has_typecheck_script() {
  if command -v node >/dev/null 2>&1; then
    node <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const scripts = pkg.scripts || {};
const aliases = ["typecheck", "check-types", "type-check", "test:types"];
if (aliases.some((k) => Object.prototype.hasOwnProperty.call(scripts, k))) process.exit(0);
if (Object.values(scripts).some((v) => /\b(tsc|tsgo)\b/.test(String(v)))) process.exit(0);
process.exit(1);
NODE
    return
  fi
  if command -v rg >/dev/null 2>&1; then
    rg -q '"(typecheck|check-types|type-check|test:types)"\s*:' package.json \
      || rg -q '\b(tsc|tsgo)\b' package.json
  else
    grep -Eq '"(typecheck|check-types|type-check|test:types)"[[:space:]]*:' package.json \
      || grep -Eq '\b(tsc|tsgo)\b' package.json
  fi
}

if ! has_typecheck_script; then
  echo "FAIL: package.json missing typecheck script (typecheck|check-types|type-check|test:types or a script invoking tsc/tsgo)"
  fail=1
fi

APP_TSCONFIG=""
for candidate in tsconfig.app.json tsconfig.json tsconfig.base.json tsconfig.build.json tsconfig.types.json; do
  if [[ -f "$candidate" ]]; then
    APP_TSCONFIG="$candidate"
    break
  fi
done

if [[ -z "$APP_TSCONFIG" ]]; then
  echo "FAIL: no tsconfig.app.json / tsconfig.json / tsconfig.base.json / tsconfig.build.json / tsconfig.types.json"
  exit 1
fi

PRIMARY="$APP_TSCONFIG"
if [[ -f tsconfig.app.json ]]; then
  PRIMARY="tsconfig.app.json"
fi

file_has_true() {
  local file="$1" key="$2"
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  if command -v rg >/dev/null 2>&1; then
    rg -q "\"$key\"\s*:\s*true" "$file"
  else
    grep -Eq "\"$key\"[[:space:]]*:[[:space:]]*true" "$file"
  fi
}

extends_target() {
  local file="$1"
  local raw=""
  if command -v rg >/dev/null 2>&1; then
    raw=$(rg -o '"extends"\s*:\s*"([^"]+)"' -r '$1' "$file" 2>/dev/null | head -1 || true)
    if [[ -z "$raw" ]]; then
      raw=$(rg -o '"extends"\s*:\s*\[\s*"([^"]+)"' -r '$1' "$file" 2>/dev/null | head -1 || true)
    fi
  else
    raw=$(grep -Eo '"extends"[[:space:]]*:[[:space:]]*"[^"]+"' "$file" 2>/dev/null | head -1 \
      | sed -E 's/.*"extends"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)
  fi
  if [[ -z "$raw" ]]; then
    echo ""
    return
  fi
  local dir base
  dir=$(dirname "$file")
  base="$raw"
  case "$base" in
    *.json) ;;
    *) base="${base}.json" ;;
  esac
  case "$base" in
    .*|/*)
      local resolved="$dir/$base"
      if [[ -f "$resolved" ]]; then
        (cd "$(dirname "$resolved")" && echo "$(pwd)/$(basename "$resolved")")
      else
        echo ""
      fi
      ;;
    *)
      echo ""
      ;;
  esac
}

chain_has_true() {
  local start="$1" key="$2"
  local current seen hops next
  current=$(cd "$(dirname "$start")" && echo "$(pwd)/$(basename "$start")")
  seen=""
  hops=0
  while [[ -n "$current" && "$hops" -lt 12 ]]; do
    case " $seen " in
      *" $current "*) break ;;
    esac
    seen="$seen $current"
    if file_has_true "$current" "$key"; then
      return 0
    fi
    next=$(extends_target "$current")
    current="$next"
    hops=$((hops + 1))
  done
  return 1
}

if ! chain_has_true "$PRIMARY" "strict"; then
  echo "FAIL: $PRIMARY (and extends chain) missing \"strict\": true (PSR: enable strict checking)"
  fail=1
  if ! chain_has_true "$PRIMARY" "noImplicitAny"; then
    echo "FAIL: $PRIMARY missing noImplicitAny (and strict not true in extends chain)"
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-strict-gate ($ROOT, $PRIMARY)"
