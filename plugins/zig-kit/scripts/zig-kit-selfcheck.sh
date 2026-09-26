#!/usr/bin/env bash
# Prove zig-kit gates discriminate fixtures (pack maturity).
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

# Parallel probes (fail aggregation after wait; subshell fail= is discarded).
probe bad-rg bash "$HERE/zig-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/zig-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/zig-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env ZIG_RG_BUDGET_MS=1 bash "$HERE/zig-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env ZIG_FMT_CONFIG_ONLY=1 bash "$HERE/zig-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env ZIG_FMT_CONFIG_ONLY=1 bash "$HERE/zig-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
probe good-build bash "$HERE/zig-build-test-gate.sh" "$ROOT/testdata/good" &
probe build-missing bash "$HERE/zig-build-test-gate.sh" "$ROOT/testdata/build-missing" &
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
check_fail tight-hot "hotpath budget fails when ZIG_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without zig fmt wiring"
check_pass good-build "build-test passes on good"
check_fail build-missing "build-test fails without zig build test wiring"

require_grep "$HERE/zig-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/zig-hotpath-gate.sh" 'ZIG_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/zig-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.zig" '@panic' "bad fixture encodes @panic"
require_grep "$ROOT/testdata/bad/smell.zig" 'catch unreachable' "bad fixture encodes catch unreachable"
require_grep "$ROOT/testdata/bad/smell.zig" 'TODO' "bad fixture encodes TODO"
require_grep "$ROOT/testdata/good/src/ok.zig" 'zig-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/try_alloc.zig" 'try|errdefer|allocator' "try_alloc template encodes try/errdefer"
require_grep "$ROOT/templates/error_return.zig" 'error\.|return error' "error_return template encodes error union"

for f in try_alloc.zig error_return.zig github-workflows/zig-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS zig-kit-selfcheck"
