#!/usr/bin/env bash
# Prove csharp-kit gates discriminate fixtures (pack maturity).
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

expect_fail bad-rg "rg fails on bad" bash "$HERE/csharp-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/csharp-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/csharp-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when CSHARP_RG_BUDGET_MS=1" env CSHARP_RG_BUDGET_MS=1 bash "$HERE/csharp-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good (config)" env CSHARP_FMT_CONFIG_ONLY=1 bash "$HERE/csharp-fmt-gate.sh" "$ROOT/testdata/good" &
expect_fail fmt-missing "fmt fails without formatter wiring" env CSHARP_FMT_CONFIG_ONLY=1 bash "$HERE/csharp-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
wait

expect_pass good-analyzers "analyzers passes with EnableNETAnalyzers" bash "$HERE/csharp-analyzers-gate.sh" "$ROOT/testdata/good"
expect_fail analyzers-missing "analyzers fails without Roslyn wiring" bash "$HERE/csharp-analyzers-gate.sh" "$ROOT/testdata/analyzers-missing"
expect_pass good-nullable "nullable passes with Nullable enable" bash "$HERE/csharp-nullable-gate.sh" "$ROOT/testdata/good"
expect_fail nullable-missing "nullable fails without enable" bash "$HERE/csharp-nullable-gate.sh" "$ROOT/testdata/nullable-missing"

require_grep "$HERE/csharp-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/csharp-hotpath-gate.sh" 'CSHARP_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/csharp-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/Smell.cs" 'Console\.WriteLine' "bad fixture encodes Console.WriteLine"
require_grep "$ROOT/testdata/bad/Smell.cs" 'SELECT' "bad fixture encodes SQL concat"
require_grep "$ROOT/testdata/bad/Smell.cs" '\.Result' "bad fixture encodes blocking async"
require_grep "$ROOT/testdata/good/src/Ok.cs" 'csharp-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/parameterized_command.cs" 'SqlParameter|Parameters\.Add' "parameterized_command template encodes params"
require_grep "$ROOT/templates/logger_not_console.cs" 'ILogger' "logger_not_console template encodes ILogger"

for f in parameterized_command.cs logger_not_console.cs editorconfig/.editorconfig github-workflows/csharp-gates.yml Directory.Build.props; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS csharp-kit-selfcheck"
