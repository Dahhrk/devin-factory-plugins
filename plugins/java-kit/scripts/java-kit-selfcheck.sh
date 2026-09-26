#!/usr/bin/env bash
# Prove java-kit gates discriminate fixtures (pack maturity).
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

expect_fail bad-rg "rg fails on bad" bash "$HERE/java-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/java-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/java-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when JAVA_RG_BUDGET_MS=1" env JAVA_RG_BUDGET_MS=1 bash "$HERE/java-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good (config)" env JAVA_FMT_CONFIG_ONLY=1 bash "$HERE/java-fmt-gate.sh" "$ROOT/testdata/good" &
expect_fail fmt-missing "fmt fails without formatter wiring" env JAVA_FMT_CONFIG_ONLY=1 bash "$HERE/java-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
wait

expect_pass good-check "checkstyle-ci passes with checkstyle.xml" bash "$HERE/java-checkstyle-ci-gate.sh" "$ROOT/testdata/good"
expect_fail check-missing "checkstyle-ci fails without Checkstyle/Error Prone" bash "$HERE/java-checkstyle-ci-gate.sh" "$ROOT/testdata/checkstyle-missing"
expect_pass good-null "nullability passes with @NullMarked" bash "$HERE/java-nullability-gate.sh" "$ROOT/testdata/good"
expect_fail null-missing "nullability fails without contracts" bash "$HERE/java-nullability-gate.sh" "$ROOT/testdata/nullability-missing"

require_grep "$HERE/java-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/java-hotpath-gate.sh" 'JAVA_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/java-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/Smell.java" 'System\.out' "bad fixture encodes System.out"
require_grep "$ROOT/testdata/bad/Smell.java" 'printStackTrace' "bad fixture encodes printStackTrace"
require_grep "$ROOT/testdata/bad/Smell.java" 'SELECT' "bad fixture encodes SQL concat"
require_grep "$ROOT/testdata/bad/Smell.java" 'NullPointerException' "bad fixture encodes NPE catch"
require_grep "$ROOT/testdata/good/src/main/java/demo/Ok.java" 'java-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/prepared_statement.java" 'PreparedStatement' "prepared_statement template encodes PreparedStatement"
require_grep "$ROOT/templates/logger_not_stdout.java" 'Logger' "logger_not_stdout template encodes Logger"

for f in prepared_statement.java logger_not_stdout.java spotless.gradle checkstyle/checkstyle.xml github-workflows/java-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS java-kit-selfcheck"
