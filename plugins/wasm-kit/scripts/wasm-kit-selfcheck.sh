#!/usr/bin/env bash
# Prove wasm-kit gates discriminate fixtures (pack maturity).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
fail=0

probe() {
  local id="$1"; shift
  if "$@" >"$WORKDIR/$id.out" 2>&1; then echo 0 >"$WORKDIR/$id.rc"; else echo 1 >"$WORKDIR/$id.rc"; fi
}

require_grep() {
  local file="$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]] || ! grep -q -E -e "$pat" -- "$file"; then
    echo "FAIL selfcheck: $label"; fail=1
  else
    echo "ok: $label"
  fi
}

probe bad-rg bash "$HERE/wasm-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/wasm-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/wasm-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env WASM_RG_BUDGET_MS=1 bash "$HERE/wasm-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-tools env WASM_TOOLS_CONFIG_ONLY=1 bash "$HERE/wasm-tools-gate.sh" "$ROOT/testdata/good" &
probe tools-missing env WASM_TOOLS_CONFIG_ONLY=1 bash "$HERE/wasm-tools-gate.sh" "$ROOT/testdata/wasm-missing" &
wait

check_fail() {
  local id="$1" label="$2"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}
check_pass() {
  local id="$1" label="$2"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}

check_fail bad-rg "rg fails on bad"
check_pass good-rg "rg passes on good"
check_pass good-hot "hotpath budget passes on good"
check_fail tight-hot "hotpath budget fails when WASM_RG_BUDGET_MS=1"
check_pass good-tools "tools passes on good (config)"
check_fail tools-missing "tools fails without wiring"

require_grep "$HERE/wasm-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/wasm-hotpath-gate.sh" 'WASM_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/wasm-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.wat" 'memory\.grow' "bad fixture encodes memory.grow"
require_grep "$ROOT/testdata/bad/smell.wat" 'call \$print|call \$log|call \$debug|import "console" "log"' "bad fixture encodes wat debug hygiene"
require_grep "$ROOT/testdata/bad/smell.wat" 'import .*"(eval|eval_js|Function|exec|js_eval)"' "bad fixture encodes host eval import"
require_grep "$ROOT/testdata/good/ok.wat" 'wasm-rg-allow|;;' "good fixture encodes allow or grow comment"
require_grep "$ROOT/testdata/good/Makefile" 'wat2wasm|wasm-tools|wabt' "good encodes wasm tooling"
require_grep "$ROOT/templates/bounded_memory_grow.wat" 'memory\.grow' "bounded_memory_grow template encodes memory.grow"
require_grep "$ROOT/templates/bounded_memory_grow.wat" ';;' "bounded_memory_grow template encodes ;; comment"
require_grep "$ROOT/templates/no_host_eval_import.wat" 'import' "no_host_eval_import template encodes import"
require_grep "$ROOT/templates/no_debug_wat.wat" 'module' "no_debug_wat template encodes module"

# no_debug_wat must not call $print/$log/$debug as live ops
if rg -n -P '(?i)\(call\s+\$(print|log|debug)\b|\(import\s+"console"\s+"log"' "$ROOT/templates/no_debug_wat.wat" >/dev/null 2>&1; then
  echo "FAIL selfcheck: no_debug_wat.wat still has debug call/import"; fail=1
else
  echo "ok: no_debug_wat.wat has no debug call/import"
fi

# no_host_eval must not import eval-shaped names
if rg -n -P '(?i)\(import\s+"[^"]*"\s+"(eval|eval_js|Function|exec|js_eval)"' "$ROOT/templates/no_host_eval_import.wat" >/dev/null 2>&1; then
  echo "FAIL selfcheck: no_host_eval_import.wat still imports eval-shaped host"; fail=1
else
  echo "ok: no_host_eval_import.wat has no eval-shaped import"
fi

for f in no_debug_wat.wat bounded_memory_grow.wat no_host_eval_import.wat github-workflows/wasm-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS wasm-kit-selfcheck"
