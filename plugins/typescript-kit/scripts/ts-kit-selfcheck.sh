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
  local id="$1"
  shift
  local out="$WORKDIR/$id.out" rc="$WORKDIR/$id.rc"
  if "$@" >"$out" 2>&1; then
    echo 0 >"$rc"
  else
    echo 1 >"$rc"
  fi
}

expect_fail() {
  local id="$1" label="$2"
  shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"
    cat "$WORKDIR/$id.out"
    echo 1 >"$WORKDIR/$id.expect"
  else
    echo "ok: $label"
    echo 0 >"$WORKDIR/$id.expect"
  fi
}

expect_pass() {
  local id="$1" label="$2"
  shift 2
  probe "$id" "$@"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"
    cat "$WORKDIR/$id.out"
    echo 1 >"$WORKDIR/$id.expect"
  else
    echo "ok: $label"
    echo 0 >"$WORKDIR/$id.expect"
  fi
}

# Launch independent gate probes in parallel
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
wait

shopt -s nullglob
for f in "$WORKDIR"/*.expect; do
  if [[ "$(cat "$f")" != "0" ]]; then fail=1; fi
done

# oxlint template must exist and name the factory-wide rules
OXLINT="$ROOT/templates/oxlintrc.json"
if [[ ! -f "$OXLINT" ]]; then
  echo "FAIL selfcheck: missing templates/oxlintrc.json"
  fail=1
else
  missing=0
  for key in no-explicit-any no-non-null-assertion switch-exhaustiveness-check ban-ts-comment no-floating-promises no-misused-promises typeAware; do
    if ! grep -q "$key" "$OXLINT"; then
      echo "FAIL selfcheck: oxlintrc missing $key"
      missing=1
    fi
  done
  if [[ "$missing" -eq 0 ]]; then
    echo "ok: oxlint template encodes any / non-null / exhaustive-switch / ban-ts-comment / floating / misused / typeAware"
  else
    fail=1
  fi
fi

# schema / typed-parse templates (encode from repeating product env/JSON smells)
for tmpl in env-schema.ts typed-parse.ts; do
  if [[ ! -f "$ROOT/templates/$tmpl" ]]; then
    echo "FAIL selfcheck: missing templates/$tmpl"
    fail=1
  else
    echo "ok: template $tmpl present"
  fi
done
if ! grep -q 'parseEnv' "$ROOT/templates/env-schema.ts" \
  || ! grep -q 'process.env' "$ROOT/templates/env-schema.ts"; then
  echo "FAIL selfcheck: env-schema template missing parseEnv / process.env"
  fail=1
else
  echo "ok: env-schema template encodes named parseEnv"
fi
if ! grep -q 'JSON.parse' "$ROOT/templates/typed-parse.ts" \
  || ! grep -q 'ts-rg-allow' "$ROOT/templates/typed-parse.ts"; then
  echo "FAIL selfcheck: typed-parse template missing JSON.parse / ts-rg-allow"
  fail=1
else
  echo "ok: typed-parse template encodes named JSON boundary"
fi

# bad fixture must mention the boundary smells (prove encode substance)
if ! grep -q 'fetch(' "$ROOT/testdata/bad/src/smell.ts" \
  || ! grep -q 'new URL' "$ROOT/testdata/bad/src/smell.ts" \
  || ! grep -q 'process.env' "$ROOT/testdata/bad/src/smell.ts"; then
  echo "FAIL selfcheck: bad fixture missing fetch/URL/env smells"
  fail=1
else
  echo "ok: bad fixture encodes fetch/URL/env"
fi

# good fixture must include method .fetch true-negative and whole-object env parse
if ! grep -q 'q.fetch()' "$ROOT/testdata/good/src/ok.ts"; then
  echo "FAIL selfcheck: good fixture missing method .fetch true-negative"
  fail=1
else
  echo "ok: good fixture encodes method .fetch true-negative"
fi
if ! grep -q 'parseAppEnv' "$ROOT/testdata/good/src/ok.ts" \
  || ! grep -q 'process.env' "$ROOT/testdata/good/src/ok.ts"; then
  echo "FAIL selfcheck: good fixture missing whole-object env parse"
  fail=1
else
  echo "ok: good fixture encodes whole-object env parse"
fi

# float-bad fixture must encode floating + misused smells
FLOAT_BAD="$ROOT/testdata/oxlint-float-bad/src/float.ts"
if [[ ! -f "$FLOAT_BAD" ]] \
  || ! grep -qx 'load()' "$FLOAT_BAD" \
  || ! grep -Fq 'onReady(async' "$FLOAT_BAD" \
  || ! grep -Fq 'setTimeout(async' "$FLOAT_BAD"; then
  echo "FAIL selfcheck: oxlint-float-bad missing floating/misused smells"
  fail=1
else
  echo "ok: oxlint-float-bad encodes floating + misused + setTimeout(async)"
fi

# Prove bare @ts-expect-error is actually caught (portable filter, not broken PCRE2 lookahead)
if ! grep -q 'ts-expect-error' "$WORKDIR/bad-rg.out" 2>/dev/null \
  && ! rg -q 'ts-expect-error' "$WORKDIR/bad-rg.out" 2>/dev/null; then
  if [[ "$(cat "$WORKDIR/bad-rg.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: bad rg unexpectedly passed"
    fail=1
  else
    if ! bash "$HERE/ts-rg-gate.sh" "$ROOT/testdata/bad" 2>&1 | tee "$WORKDIR/bad-rg-retry.out" | grep -q 'ts-expect-error requires'; then
      echo "FAIL selfcheck: bare @ts-expect-error not reported"
      cat "$WORKDIR/bad-rg-retry.out"
      fail=1
    else
      echo "ok: bare @ts-expect-error discriminated"
    fi
  fi
else
  echo "ok: bare @ts-expect-error discriminated"
fi

# Oxlint pin: never @latest; version stamps + gate defaults agree; offline refuses npx
OXLINT_GATE="$HERE/ts-oxlint-gate.sh"
PIN_FILE="$ROOT/templates/oxlint.version"
TSG_PIN_FILE="$ROOT/templates/oxlint-tsgolint.version"
if [[ ! -f "$PIN_FILE" ]]; then
  echo "FAIL selfcheck: missing templates/oxlint.version"
  fail=1
else
  PIN="$(tr -d '[:space:]' <"$PIN_FILE")"
  if [[ -z "$PIN" ]]; then
    echo "FAIL selfcheck: empty oxlint.version"
    fail=1
  elif ! grep -Fq "$PIN" "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate missing pin $PIN"
    fail=1
  else
    echo "ok: oxlint gate pins $PIN"
  fi
  if grep -F -q 'oxlint@latest' "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate still invokes @latest"
    fail=1
  elif ! grep -F -q 'oxlint@${TS_OXLINT_VERSION}' "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate missing pinned npx oxlint@\${TS_OXLINT_VERSION}"
    fail=1
  else
    echo "ok: oxlint gate avoids @latest (uses pin)"
  fi
  if ! grep -q 'TS_OXLINT_OFFLINE' "$OXLINT_GATE" \
    || ! grep -q 'TS_OXLINT_BIN' "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate missing TS_OXLINT_OFFLINE / TS_OXLINT_BIN"
    fail=1
  else
    echo "ok: oxlint gate encodes OFFLINE + BIN overrides"
  fi
fi

if [[ ! -f "$TSG_PIN_FILE" ]]; then
  echo "FAIL selfcheck: missing templates/oxlint-tsgolint.version"
  fail=1
else
  TSG_PIN="$(tr -d '[:space:]' <"$TSG_PIN_FILE")"
  if [[ -z "$TSG_PIN" ]]; then
    echo "FAIL selfcheck: empty oxlint-tsgolint.version"
    fail=1
  elif ! grep -Fq "$TSG_PIN" "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate missing tsgolint pin $TSG_PIN"
    fail=1
  else
    echo "ok: oxlint gate pins tsgolint $TSG_PIN"
  fi
  if ! grep -q 'oxlint-tsgolint@\${TS_OXLINT_TSGOLINT_VERSION}' "$OXLINT_GATE" \
    && ! grep -F -q 'oxlint-tsgolint@${TS_OXLINT_TSGOLINT_VERSION}' "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate missing pinned oxlint-tsgolint@\${TS_OXLINT_TSGOLINT_VERSION}"
    fail=1
  else
    echo "ok: oxlint gate npx dual-pins oxlint-tsgolint"
  fi
  if ! grep -q -- '--type-aware' "$OXLINT_GATE"; then
    echo "FAIL selfcheck: oxlint gate missing --type-aware live flag"
    fail=1
  else
    echo "ok: oxlint gate live path passes --type-aware"
  fi
fi

# Offline mode must fail clearly when no local binary (do not fall through to npx)
OFF_OUT="$WORKDIR/oxlint-offline.out"
OFF_RC=0
env -u TS_OXLINT_BIN -u TS_OXLINT_CONFIG_ONLY -u TS_OXLINT_TSGOLINT_BIN PATH="/usr/bin:/bin" \
  TS_OXLINT_OFFLINE=1 bash "$OXLINT_GATE" "$ROOT/testdata/good" >"$OFF_OUT" 2>&1 || OFF_RC=$?
if [[ "$OFF_RC" -eq 0 ]]; then
  echo "FAIL selfcheck: TS_OXLINT_OFFLINE=1 unexpectedly passed without local oxlint"
  cat "$OFF_OUT"
  fail=1
elif ! grep -q 'offline oxlint required' "$OFF_OUT"; then
  echo "FAIL selfcheck: offline miss missing clear FAIL message"
  cat "$OFF_OUT"
  fail=1
else
  echo "ok: offline oxlint refuses network/npx fallback"
fi

# Live type-aware proof when local oxlint+tsgolint exist, or via npx dual-package
run_typeaware_live=0
if [[ -n "${TS_OXLINT_BIN:-}" ]] && { command -v tsgolint >/dev/null 2>&1 || [[ -n "${TS_OXLINT_TSGOLINT_BIN:-}" ]]; }; then
  run_typeaware_live=1
elif command -v oxlint >/dev/null 2>&1 && command -v tsgolint >/dev/null 2>&1; then
  run_typeaware_live=1
elif [[ -x /tmp/oxlint-float-proof/node_modules/.bin/oxlint ]] \
  && [[ -x /tmp/oxlint-float-proof/node_modules/.bin/tsgolint ]]; then
  export TS_OXLINT_BIN=/tmp/oxlint-float-proof/node_modules/.bin/oxlint
  export PATH="/tmp/oxlint-float-proof/node_modules/.bin:$PATH"
  run_typeaware_live=1
elif command -v npx >/dev/null 2>&1 && [[ "${TS_OXLINT_SELFCHECK_OFFLINE:-}" != "1" ]]; then
  run_typeaware_live=2
fi

if [[ "$run_typeaware_live" -eq 1 ]]; then
  if TS_OXLINT_OFFLINE=1 bash "$OXLINT_GATE" "$ROOT/testdata/oxlint-float-bad" >"$WORKDIR/oxlint-float-live.out" 2>&1; then
    echo "FAIL selfcheck: type-aware live unexpectedly passed on oxlint-float-bad"
    cat "$WORKDIR/oxlint-float-live.out"
    fail=1
  elif ! grep -Eq 'no-floating-promises|no-misused-promises' "$WORKDIR/oxlint-float-live.out"; then
    echo "FAIL selfcheck: type-aware live miss missing floating/misused diagnostics"
    cat "$WORKDIR/oxlint-float-live.out"
    fail=1
  else
    echo "ok: type-aware live fails oxlint-float-bad (floating/misused)"
  fi
elif [[ "$run_typeaware_live" -eq 2 ]]; then
  PIN="$(tr -d '[:space:]' <"$PIN_FILE")"
  TSG_PIN="$(tr -d '[:space:]' <"$TSG_PIN_FILE")"
  if (cd "$ROOT/testdata/oxlint-float-bad" && npx --yes -p "oxlint@$PIN" -p "oxlint-tsgolint@$TSG_PIN" oxlint --type-aware -c .oxlintrc.json .) \
    >"$WORKDIR/oxlint-float-npx.out" 2>&1; then
    echo "FAIL selfcheck: npx type-aware unexpectedly passed on oxlint-float-bad"
    cat "$WORKDIR/oxlint-float-npx.out"
    fail=1
  elif ! grep -Eq 'no-floating-promises|no-misused-promises' "$WORKDIR/oxlint-float-npx.out"; then
    echo "FAIL selfcheck: npx type-aware miss missing floating/misused diagnostics"
    cat "$WORKDIR/oxlint-float-npx.out"
    fail=1
  else
    echo "ok: npx type-aware fails oxlint-float-bad (floating/misused)"
  fi
else
  echo "ok: skip live type-aware (no local oxlint+tsgolint; pin+config proven; set bins or unset TS_OXLINT_SELFCHECK_OFFLINE)"
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS ts-kit-selfcheck"
