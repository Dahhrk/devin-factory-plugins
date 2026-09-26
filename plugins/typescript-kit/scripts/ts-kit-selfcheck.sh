#!/usr/bin/env bash
# Prove typescript-kit gates discriminate fixtures (pack maturity).
# Hot-path: independent probes run concurrently; aggregate rc files.
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
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; echo 1 >"$WORKDIR/$id.expect"; fail=1
  else
    echo "ok: $label"; echo 0 >"$WORKDIR/$id.expect"
  fi
}

expect_pass() {
  local id="$1" label="$2"; shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; echo 1 >"$WORKDIR/$id.expect"; fail=1
  else
    echo "ok: $label"; echo 0 >"$WORKDIR/$id.expect"
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

require_fgrep() {
  local file="$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]] || ! grep -q -F -e "$pat" -- "$file"; then
    echo "FAIL selfcheck: $label"; fail=1
  else
    echo "ok: $label"
  fi
}

# Parallel gate probes
expect_fail bad-rg "rg fails on bad" bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/bad" &
expect_pass good-rg "rg passes on good" bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/good" &
expect_pass good-strict "strict passes on good" bash "$HERE/ts-strict-gate.sh" "$ROOT/testdata/good" &
expect_pass good-runtime "runtime passes on good" bash "$HERE/ts-runtime-gate.sh" "$ROOT/testdata/good" &
expect_pass good-oxlint "oxlint passes on good" env TS_OXLINT_CONFIG_ONLY=1 bash "$HERE/ts-oxlint-gate.sh" "$ROOT/testdata/good" &
expect_pass extends-ok "strict walks extends" bash "$HERE/ts-strict-gate.sh" "$ROOT/testdata/extends-ok" &
expect_fail strict-missing "strict fails when missing" bash "$HERE/ts-strict-gate.sh" "$ROOT/testdata/strict-missing" &
expect_fail runtime-missing "runtime fails when missing" bash "$HERE/ts-runtime-gate.sh" "$ROOT/testdata/runtime-missing" &
expect_fail oxlint-missing "oxlint fails when config missing" env TS_OXLINT_CONFIG_ONLY=1 bash "$HERE/ts-oxlint-gate.sh" "$ROOT/testdata/oxlint-missing" &
expect_fail oxlint-weak "oxlint fails when factory rules missing" env TS_OXLINT_CONFIG_ONLY=1 bash "$HERE/ts-oxlint-gate.sh" "$ROOT/testdata/oxlint-weak" &
expect_fail oxlint-typeaware-missing "oxlint fails when typeAware/floating/misused missing" env TS_OXLINT_CONFIG_ONLY=1 bash "$HERE/ts-oxlint-gate.sh" "$ROOT/testdata/oxlint-typeaware-missing" &
expect_fail lib-product "product mode flags .d.ts any" bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/library-dts" &
expect_pass lib-skip "library mode skips .d.ts any" env TS_RG_SKIP_DTS=1 bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/library-dts" &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/ts-hotpath-gate.sh" "$ROOT/testdata/good" &
expect_fail tight-hot "hotpath budget fails when TS_RG_BUDGET_MS=1" env TS_RG_BUDGET_MS=1 bash "$HERE/ts-hotpath-gate.sh" "$ROOT/testdata/good" &
wait

shopt -s nullglob
for f in "$WORKDIR"/*.expect; do
  [[ "$(cat "$f")" == "0" ]] || fail=1
done

OXLINT="$ROOT/templates/oxlintrc.json"
OXLINT_GATE="$HERE/ts-oxlint-gate.sh"
PIN_FILE="$ROOT/templates/oxlint.version"
TSG_PIN_FILE="$ROOT/templates/oxlint-tsgolint.version"
RG_GATE="$HERE/ts-rg-gate.sh"
HOT_GATE="$HERE/ts-hotpath-gate.sh"

if [[ ! -f "$OXLINT" ]]; then
  echo "FAIL selfcheck: missing templates/oxlintrc.json"; fail=1
else
  missing=0
  for key in no-explicit-any no-non-null-assertion switch-exhaustiveness-check ban-ts-comment no-floating-promises no-misused-promises typeAware; do
    grep -q "$key" "$OXLINT" || { echo "FAIL selfcheck: oxlintrc missing $key"; missing=1; }
  done
  if [[ "$missing" -eq 0 ]]; then
    echo "ok: oxlint template encodes any / non-null / exhaustive-switch / ban-ts-comment / floating / misused / typeAware"
  else fail=1; fi
fi

for tmpl in env-schema.ts typed-parse.ts; do
  if [[ ! -f "$ROOT/templates/$tmpl" ]]; then
    echo "FAIL selfcheck: missing templates/$tmpl"; fail=1
  else echo "ok: template $tmpl present"; fi
done
require_grep "$ROOT/templates/env-schema.ts" 'parseEnv' "env-schema template encodes named parseEnv"
require_grep "$ROOT/templates/env-schema.ts" 'process\.env' "env-schema mentions process.env"
require_grep "$ROOT/templates/typed-parse.ts" 'JSON\.parse' "typed-parse template encodes named JSON boundary"
require_grep "$ROOT/templates/typed-parse.ts" 'ts-rg-allow' "typed-parse carries ts-rg-allow"
require_grep "$ROOT/testdata/bad/src/smell.ts" 'fetch\(' "bad fixture encodes fetch"
require_grep "$ROOT/testdata/bad/src/smell.ts" 'new URL' "bad fixture encodes URL"
require_grep "$ROOT/testdata/bad/src/smell.ts" 'process\.env' "bad fixture encodes env"
require_grep "$ROOT/testdata/good/src/ok.ts" 'q\.fetch\(\)' "good fixture encodes method .fetch true-negative"
require_grep "$ROOT/testdata/good/src/ok.ts" 'parseAppEnv' "good fixture encodes whole-object env parse"
require_grep "$ROOT/testdata/oxlint-float-bad/src/float.ts" '^load\(\)$' "oxlint-float-bad encodes floating load()"
require_grep "$ROOT/testdata/oxlint-float-bad/src/float.ts" 'onReady\(async' "oxlint-float-bad encodes misused onReady"
require_grep "$ROOT/testdata/oxlint-float-bad/src/float.ts" 'setTimeout\(async' "oxlint-float-bad encodes setTimeout(async)"

# bare @ts-expect-error discrimination
if grep -q 'ts-expect-error requires' "$WORKDIR/bad-rg.out" 2>/dev/null; then
  echo "ok: bare @ts-expect-error discriminated"
elif bash "$RG_GATE" "$ROOT/testdata/bad" 2>&1 | tee "$WORKDIR/bad-rg-retry.out" | grep -q 'ts-expect-error requires'; then
  echo "ok: bare @ts-expect-error discriminated"
else
  echo "FAIL selfcheck: bare @ts-expect-error not reported"
  cat "$WORKDIR/bad-rg.out" 2>/dev/null || true
  cat "$WORKDIR/bad-rg-retry.out" 2>/dev/null || true
  fail=1
fi

# Pins + live flags
if [[ ! -f "$PIN_FILE" || ! -f "$TSG_PIN_FILE" ]]; then
  echo "FAIL selfcheck: missing oxlint / oxlint-tsgolint version stamps"; fail=1
else
  PIN="$(tr -d '[:space:]' <"$PIN_FILE")"
  TSG_PIN="$(tr -d '[:space:]' <"$TSG_PIN_FILE")"
  require_fgrep "$OXLINT_GATE" "$PIN" "oxlint gate pins $PIN"
  require_fgrep "$OXLINT_GATE" "$TSG_PIN" "oxlint gate pins tsgolint $TSG_PIN"
  if grep -F -q 'oxlint@latest' "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate still invokes @latest"; fail=1
  else echo "ok: oxlint gate avoids @latest (uses pin)"; fi
  require_fgrep "$OXLINT_GATE" 'oxlint@${TS_OXLINT_VERSION}' "oxlint gate uses pinned npx oxlint"
  require_fgrep "$OXLINT_GATE" 'oxlint-tsgolint@${TS_OXLINT_TSGOLINT_VERSION}' "oxlint gate npx dual-pins oxlint-tsgolint"
  require_fgrep "$OXLINT_GATE" 'TS_OXLINT_OFFLINE' "oxlint gate encodes OFFLINE"
  require_fgrep "$OXLINT_GATE" 'TS_OXLINT_BIN' "oxlint gate encodes BIN overrides"
  require_fgrep "$OXLINT_GATE" '--type-aware' "oxlint gate live path passes --type-aware"
fi

require_grep "$RG_GATE" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HOT_GATE" 'TS_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HOT_GATE" '250' "hotpath gate default budget 250ms"

# Offline refuses npx
OFF_OUT="$WORKDIR/oxlint-offline.out"; OFF_RC=0
env -u TS_OXLINT_BIN -u TS_OXLINT_CONFIG_ONLY -u TS_OXLINT_TSGOLINT_BIN PATH="/usr/bin:/bin" \
  TS_OXLINT_OFFLINE=1 bash "$OXLINT_GATE" "$ROOT/testdata/good" >"$OFF_OUT" 2>&1 || OFF_RC=$?
if [[ "$OFF_RC" -eq 0 ]]; then
  echo "FAIL selfcheck: TS_OXLINT_OFFLINE=1 unexpectedly passed"; cat "$OFF_OUT"; fail=1
elif ! grep -q 'offline oxlint required' "$OFF_OUT"; then
  echo "FAIL selfcheck: offline miss missing clear FAIL message"; cat "$OFF_OUT"; fail=1
else
  echo "ok: offline oxlint refuses network/npx fallback"
fi

# Live type-aware proof
run_typeaware_live=0
if [[ -n "${TS_OXLINT_BIN:-}" ]] && { command -v tsgolint >/dev/null 2>&1 || [[ -n "${TS_OXLINT_TSGOLINT_BIN:-}" ]]; }; then
  run_typeaware_live=1
elif command -v oxlint >/dev/null 2>&1 && command -v tsgolint >/dev/null 2>&1; then
  run_typeaware_live=1
elif [[ -x /tmp/oxlint-float-proof/node_modules/.bin/oxlint && -x /tmp/oxlint-float-proof/node_modules/.bin/tsgolint ]]; then
  export TS_OXLINT_BIN=/tmp/oxlint-float-proof/node_modules/.bin/oxlint
  export PATH="/tmp/oxlint-float-proof/node_modules/.bin:$PATH"
  run_typeaware_live=1
elif command -v npx >/dev/null 2>&1 && [[ "${TS_OXLINT_SELFCHECK_OFFLINE:-}" != "1" ]]; then
  run_typeaware_live=2
fi

if [[ "$run_typeaware_live" -eq 1 ]]; then
  if TS_OXLINT_OFFLINE=1 bash "$OXLINT_GATE" "$ROOT/testdata/oxlint-float-bad" >"$WORKDIR/oxlint-float-live.out" 2>&1; then
    echo "FAIL selfcheck: type-aware live unexpectedly passed on oxlint-float-bad"; cat "$WORKDIR/oxlint-float-live.out"; fail=1
  elif ! grep -Eq 'no-floating-promises|no-misused-promises' "$WORKDIR/oxlint-float-live.out"; then
    echo "FAIL selfcheck: type-aware live miss missing floating/misused diagnostics"; cat "$WORKDIR/oxlint-float-live.out"; fail=1
  else echo "ok: type-aware live fails oxlint-float-bad (floating/misused)"; fi
elif [[ "$run_typeaware_live" -eq 2 ]]; then
  PIN="$(tr -d '[:space:]' <"$PIN_FILE")"
  TSG_PIN="$(tr -d '[:space:]' <"$TSG_PIN_FILE")"
  if (cd "$ROOT/testdata/oxlint-float-bad" && npx --yes -p "oxlint@$PIN" -p "oxlint-tsgolint@$TSG_PIN" oxlint --type-aware -c .oxlintrc.json .) \
    >"$WORKDIR/oxlint-float-npx.out" 2>&1; then
    echo "FAIL selfcheck: npx type-aware unexpectedly passed"; cat "$WORKDIR/oxlint-float-npx.out"; fail=1
  elif ! grep -Eq 'no-floating-promises|no-misused-promises' "$WORKDIR/oxlint-float-npx.out"; then
    echo "FAIL selfcheck: npx type-aware miss missing floating/misused diagnostics"; cat "$WORKDIR/oxlint-float-npx.out"; fail=1
  else echo "ok: npx type-aware fails oxlint-float-bad (floating/misused)"; fi
else
  echo "ok: skip live type-aware (no local oxlint+tsgolint; pin+config proven)"
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS ts-kit-selfcheck"
