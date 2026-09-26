#!/usr/bin/env bash
# Tier 0.5: require a runtime / drive proof script in package.json.
# Types alone are not Done (PSR: test emitted/runtime behaviour).
#
# Accepted script names: test, smoke, test:e2e, test:runtime, playwright,
# vitest, jest, cypress. Or any script whose command invokes those tools /
# node --test.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ ! -f package.json ]]; then
  echo "FAIL: package.json missing"
  exit 1
fi

has_runtime_script() {
  if command -v node >/dev/null 2>&1; then
    node <<'NODE'
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const scripts = pkg.scripts || {};
const names = [
  "test",
  "smoke",
  "test:e2e",
  "test:runtime",
  "playwright",
  "vitest",
  "jest",
  "cypress",
];
if (names.some((k) => Object.prototype.hasOwnProperty.call(scripts, k))) process.exit(0);
const invoker =
  /\b(playwright|vitest|jest|cypress|mocha|node\s+--test|npm\s+run\s+test)\b/;
if (Object.values(scripts).some((v) => invoker.test(String(v)))) process.exit(0);
process.exit(1);
NODE
    return
  fi
  if command -v rg >/dev/null 2>&1; then
    rg -q '"(test|smoke|test:e2e|test:runtime|playwright|vitest|jest|cypress)"\s*:' package.json \
      || rg -q '\b(playwright|vitest|jest|cypress|mocha|node --test)\b' package.json
  else
    grep -Eq '"(test|smoke|test:e2e|test:runtime|playwright|vitest|jest|cypress)"[[:space:]]*:' package.json \
      || grep -Eq '\b(playwright|vitest|jest|cypress|mocha|node --test)\b' package.json
  fi
}

if ! has_runtime_script; then
  echo "FAIL: package.json missing runtime/drive proof script (test|smoke|test:e2e|test:runtime|playwright|vitest|jest|cypress, or a script invoking those / node --test)"
  exit 1
fi

echo "PASS ts-runtime-gate ($ROOT)"
