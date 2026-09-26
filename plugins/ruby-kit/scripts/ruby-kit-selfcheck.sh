#!/usr/bin/env bash
# Prove ruby-kit gates discriminate fixtures (pack maturity).
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

expect_fail() {
  local id="$1" label="$2"; shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}

expect_pass() {
  local id="$1" label="$2"; shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
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
probe bad-rg bash "$HERE/ruby-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/ruby-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/ruby-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env RUBY_RG_BUDGET_MS=1 bash "$HERE/ruby-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env RUBY_FMT_CONFIG_ONLY=1 bash "$HERE/ruby-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env RUBY_FMT_CONFIG_ONLY=1 bash "$HERE/ruby-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
probe good-perf bash "$HERE/ruby-rubocop-performance-gate.sh" "$ROOT/testdata/good" &
probe perf-missing bash "$HERE/ruby-rubocop-performance-gate.sh" "$ROOT/testdata/perf-missing" &
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
check_fail tight-hot "hotpath budget fails when RUBY_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without rubocop wiring"
check_pass good-perf "rubocop-performance passes on good"
check_fail perf-missing "rubocop-performance fails without plugin"

require_grep "$HERE/ruby-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/ruby-hotpath-gate.sh" 'RUBY_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/ruby-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.rb" 'eval\(' "bad fixture encodes eval"
require_grep "$ROOT/testdata/bad/smell.rb" 'public_send\(|send\(' "bad fixture encodes send smell"
require_grep "$ROOT/testdata/bad/smell.rb" '\.where\(' "bad fixture encodes where interpolate"
require_grep "$ROOT/testdata/good/app/ok.rb" 'ruby-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/parameterized_where.rb" 'where\(|\?' "parameterized_where template encodes binds"
require_grep "$ROOT/templates/allowlisted_dispatch.rb" 'allowlist|public_send|dispatch' "allowlisted_dispatch template encodes safe dispatch"

for f in parameterized_where.rb allowlisted_dispatch.rb rubocop.yml github-workflows/ruby-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ruby-kit-selfcheck"
