#!/usr/bin/env bash
# Prove kotlin-kit gates discriminate fixtures (pack maturity).
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
probe bad-rg bash "$HERE/kotlin-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/kotlin-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/kotlin-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env KOTLIN_RG_BUDGET_MS=1 bash "$HERE/kotlin-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env KOTLIN_FMT_CONFIG_ONLY=1 bash "$HERE/kotlin-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env KOTLIN_FMT_CONFIG_ONLY=1 bash "$HERE/kotlin-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
probe good-detekt bash "$HERE/kotlin-detekt-gate.sh" "$ROOT/testdata/good" &
probe detekt-missing bash "$HERE/kotlin-detekt-gate.sh" "$ROOT/testdata/lint-missing" &
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
check_fail tight-hot "hotpath budget fails when KOTLIN_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without ktlint wiring"
check_pass good-detekt "detekt passes on good"
check_fail detekt-missing "detekt fails without detekt wiring"

require_grep "$HERE/kotlin-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/kotlin-hotpath-gate.sh" 'KOTLIN_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/kotlin-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/Smell.kt" '!!' "bad fixture encodes force unwrap"
require_grep "$ROOT/testdata/bad/Smell.kt" 'runBlocking' "bad fixture encodes runBlocking"
require_grep "$ROOT/testdata/bad/Smell.kt" 'SELECT' "bad fixture encodes SQL concat"
require_grep "$ROOT/testdata/good/src/main/kotlin/demo/Ok.kt" 'kotlin-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/optional_bind.kt" '\?\.|\?:|requireNotNull' "optional_bind template encodes bind"
require_grep "$ROOT/templates/prepared_statement.kt" 'prepareStatement|PreparedStatement|\?' "prepared_statement template encodes binds"

for f in optional_bind.kt prepared_statement.kt .editorconfig detekt.yml github-workflows/kotlin-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS kotlin-kit-selfcheck"
