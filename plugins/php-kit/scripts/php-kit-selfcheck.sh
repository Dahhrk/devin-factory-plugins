#!/usr/bin/env bash
# Prove php-kit gates discriminate fixtures (pack maturity).
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
probe bad-rg bash "$HERE/php-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/php-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/php-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env PHP_RG_BUDGET_MS=1 bash "$HERE/php-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env PHP_FMT_CONFIG_ONLY=1 bash "$HERE/php-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env PHP_FMT_CONFIG_ONLY=1 bash "$HERE/php-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
probe good-stan bash "$HERE/php-stan-gate.sh" "$ROOT/testdata/good" &
probe stan-missing bash "$HERE/php-stan-gate.sh" "$ROOT/testdata/stan-missing" &
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
check_fail tight-hot "hotpath budget fails when PHP_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without pint/php-cs-fixer wiring"
check_pass good-stan "stan passes on good"
check_fail stan-missing "stan fails without phpstan/psalm"

require_grep "$HERE/php-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/php-hotpath-gate.sh" 'PHP_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/php-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.php" 'eval\(' "bad fixture encodes eval"
require_grep "$ROOT/testdata/bad/smell.php" 'unserialize\(' "bad fixture encodes unserialize"
require_grep "$ROOT/testdata/bad/smell.php" 'SELECT|whereRaw' "bad fixture encodes SQL concat"
require_grep "$ROOT/testdata/good/src/ok.php" 'php-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/parameterized_query.php" 'prepare|bind|placeholder|\?' "parameterized_query template encodes binds"
require_grep "$ROOT/templates/safe_unserialize.php" 'allowed_classes|json_decode' "safe_unserialize template encodes safe decode"

for f in parameterized_query.php safe_unserialize.php pint.json phpstan.neon.dist github-workflows/php-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS php-kit-selfcheck"
