#!/usr/bin/env bash
# Prove sql-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/sql-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/sql-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/sql-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env SQL_RG_BUDGET_MS=1 bash "$HERE/sql-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-sqlfluff env SQL_SQLFLUFF_CONFIG_ONLY=1 bash "$HERE/sql-sqlfluff-gate.sh" "$ROOT/testdata/good" &
probe sqlfluff-missing env SQL_SQLFLUFF_CONFIG_ONLY=1 bash "$HERE/sql-sqlfluff-gate.sh" "$ROOT/testdata/sqlfluff-missing" &
probe sqlfluff-weak env SQL_SQLFLUFF_CONFIG_ONLY=1 bash "$HERE/sql-sqlfluff-gate.sh" "$ROOT/testdata/sqlfluff-weak" &
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
check_fail tight-hot "hotpath budget fails when SQL_RG_BUDGET_MS=1"
check_pass good-sqlfluff "sqlfluff passes on good (config)"
check_fail sqlfluff-missing "sqlfluff fails without wiring"
check_fail sqlfluff-weak "sqlfluff fails without AM04/ambiguous encode"

require_grep "$HERE/sql-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/sql-hotpath-gate.sh" 'SQL_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/sql-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.sql" 'SELECT \*' "bad fixture encodes SELECT *"
require_grep "$ROOT/testdata/bad/smell.sql" 'EXECUTE IMMEDIATE|EXEC[[:space:]]*\(|sp_executesql' "bad fixture encodes unsafe dynamic SQL"
require_grep "$ROOT/testdata/bad/smell.sql" '\+' "bad fixture encodes SQL concat"
require_grep "$ROOT/testdata/good/ok.sql" 'sql-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/.sqlfluff" 'AM04|ambiguous' "good .sqlfluff encodes AM04/ambiguous"
require_grep "$ROOT/templates/parameterized_query.sql" '\$[0-9]|\?|:[A-Za-z_]|@\w+' "parameterized_query template encodes binds"
require_grep "$ROOT/templates/safe_dynamic.sql" 'sql-rg-allow|parameter|bind' "safe_dynamic template documents boundary"

for f in parameterized_query.sql safe_dynamic.sql .sqlfluff github-workflows/sql-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS sql-kit-selfcheck"
