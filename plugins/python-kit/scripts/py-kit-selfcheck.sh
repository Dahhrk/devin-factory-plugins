#!/usr/bin/env bash
# Prove python-kit gates discriminate fixtures (pack maturity).
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

# Parallel probes
expect_fail bad-rg "rg fails on bad" bash "$HERE/py-rg-gate.sh" "$ROOT/testdata/bad" &
expect_pass good-rg "rg passes on good" bash "$HERE/py-rg-gate.sh" "$ROOT/testdata/good" &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/py-hotpath-gate.sh" "$ROOT/testdata/good" &
expect_fail tight-hot "hotpath budget fails when PY_RG_BUDGET_MS=1" env PY_RG_BUDGET_MS=1 bash "$HERE/py-hotpath-gate.sh" "$ROOT/testdata/good" &
expect_pass good-ruff "ruff config passes on good" env PY_RUFF_CONFIG_ONLY=1 bash "$HERE/py-ruff-gate.sh" "$ROOT/testdata/good" &
expect_fail ruff-missing "ruff fails when config missing" env PY_RUFF_CONFIG_ONLY=1 bash "$HERE/py-ruff-gate.sh" "$ROOT/testdata/ruff-missing" &
expect_fail ruff-weak "ruff fails when E/F/B missing" env PY_RUFF_CONFIG_ONLY=1 bash "$HERE/py-ruff-gate.sh" "$ROOT/testdata/ruff-weak" &
expect_pass good-typing "typing passes on good" bash "$HERE/py-typing-gate.sh" "$ROOT/testdata/good" &
expect_fail typing-missing "typing fails when missing" bash "$HERE/py-typing-gate.sh" "$ROOT/testdata/typing-missing" &
expect_pass good-test "test gate passes on good" bash "$HERE/py-test-gate.sh" "$ROOT/testdata/good" &
expect_fail test-missing "test gate fails when missing" bash "$HERE/py-test-gate.sh" "$ROOT/testdata/test-missing" &
wait

require_grep "$HERE/py-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/py-hotpath-gate.sh" 'PY_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/py-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.py" 'except:' "bad fixture encodes bare except"
require_grep "$ROOT/testdata/bad/smell.py" 'type: ignore$' "bad fixture encodes bare type: ignore"
require_grep "$ROOT/testdata/bad/smell.py" 'shell[[:space:]]*=[[:space:]]*True' "bad fixture encodes shell=True"
require_grep "$ROOT/testdata/good/ok.py" 'py-rg-allow' "good fixture encodes allow on named boundary"
require_grep "$ROOT/templates/env_schema.py" 'parse_env' "env_schema template encodes parse_env"
require_grep "$ROOT/templates/typed_parse.py" 'json\.loads' "typed_parse template encodes json.loads"
require_grep "$ROOT/templates/typed_parse.py" 'py-rg-allow' "typed_parse carries py-rg-allow"
require_grep "$ROOT/templates/ruff.toml" 'select' "ruff template encodes select"

for f in env_schema.py typed_parse.py ruff.toml github-workflows/py-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

# Live ruff on good when available
if command -v ruff >/dev/null 2>&1; then
  expect_pass good-ruff-live "ruff live passes on good" bash "$HERE/py-ruff-gate.sh" "$ROOT/testdata/good"
else
  echo "ok: ruff not installed; skipped live probe"
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS py-kit-selfcheck"
