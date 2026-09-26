#!/usr/bin/env bash
# Prove elixir-kit gates discriminate fixtures (pack maturity).
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
probe bad-rg bash "$HERE/elixir-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/elixir-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/elixir-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env ELIXIR_RG_BUDGET_MS=1 bash "$HERE/elixir-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env ELIXIR_FMT_CONFIG_ONLY=1 bash "$HERE/elixir-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env ELIXIR_FMT_CONFIG_ONLY=1 bash "$HERE/elixir-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
probe good-credo bash "$HERE/elixir-credo-gate.sh" "$ROOT/testdata/good" &
probe credo-missing bash "$HERE/elixir-credo-gate.sh" "$ROOT/testdata/credo-missing" &
probe good-dialyzer bash "$HERE/elixir-dialyzer-gate.sh" "$ROOT/testdata/good" &
probe dialyzer-missing bash "$HERE/elixir-dialyzer-gate.sh" "$ROOT/testdata/dialyzer-missing" &
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
check_fail tight-hot "hotpath budget fails when ELIXIR_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without mix format wiring"
check_pass good-credo "credo passes on good"
check_fail credo-missing "credo fails without Credo wiring"
check_pass good-dialyzer "dialyzer passes on good"
check_fail dialyzer-missing "dialyzer fails without dialyzer wiring"

require_grep "$HERE/elixir-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/elixir-hotpath-gate.sh" 'ELIXIR_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/elixir-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.ex" 'String.to_atom' "bad fixture encodes String.to_atom"
require_grep "$ROOT/testdata/bad/smell.ex" 'Process.sleep' "bad fixture encodes Process.sleep"
require_grep "$ROOT/testdata/bad/smell.ex" 'SELECT' "bad fixture encodes SQL concat"
require_grep "$ROOT/testdata/good/lib/ok.ex" 'elixir-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/safe_atom.ex" 'to_existing_atom|existing_atom' "safe_atom template encodes to_existing_atom"
require_grep "$ROOT/templates/prepared_query.ex" 'Repo\.(query|all)|Ecto|\\?' "prepared_query template encodes parameterized query"

for f in safe_atom.ex prepared_query.ex .formatter.exs .credo.exs github-workflows/elixir-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS elixir-kit-selfcheck"
