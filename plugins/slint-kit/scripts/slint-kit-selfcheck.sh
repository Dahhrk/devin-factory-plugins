#!/usr/bin/env bash
# Prove slint-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/slint-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/slint-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/slint-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env SLINT_RG_BUDGET_MS=1 bash "$HERE/slint-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-cargo env SLINT_CARGO_CONFIG_ONLY=1 bash "$HERE/slint-cargo-gate.sh" "$ROOT/testdata/good" &
probe cargo-missing env SLINT_CARGO_CONFIG_ONLY=1 bash "$HERE/slint-cargo-gate.sh" "$ROOT/testdata/slint-missing" &
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
check_fail tight-hot "hotpath budget fails when SLINT_RG_BUDGET_MS=1"
check_pass good-cargo "cargo passes on good (config)"
check_fail cargo-missing "cargo fails without wiring"

require_grep "$HERE/slint-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/slint-hotpath-gate.sh" 'SLINT_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/slint-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.slint" 'debug\(' "bad fixture encodes debug()"
require_grep "$ROOT/testdata/bad/smell_callback.rs" 'clone_strong' "bad fixture encodes clone_strong"
require_grep "$ROOT/testdata/bad/smell_callback.rs" 'unsafe[[:space:]]*\{' "bad fixture encodes unsafe block"
require_grep "$ROOT/testdata/bad/smell_callback.rs" '\.on_bang' "bad fixture encodes .on_ callback host"
require_grep "$ROOT/testdata/good/ok.slint" 'slint-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/Cargo.toml" 'slint' "good encodes slint Cargo dep"
require_grep "$ROOT/templates/as_weak_callback.rs" 'as_weak' "as_weak_callback template encodes as_weak"
require_grep "$ROOT/templates/safe_callback_host.rs" 'as_weak' "safe_callback_host template encodes as_weak"

if grep -qE '^[^*]*\bdebug\s*\(' "$ROOT/templates/no_debug_slint.slint" 2>/dev/null; then
  # Allow debug only inside // comments
  if rg -n -P '^(?!\s*//).*?\bdebug\s*\(' "$ROOT/templates/no_debug_slint.slint" >/dev/null 2>&1; then
    echo "FAIL selfcheck: no_debug_slint.slint still calls debug("; fail=1
  else
    echo "ok: no_debug_slint.slint has no debug() call"
  fi
else
  echo "ok: no_debug_slint.slint has no debug() call"
fi

for f in no_debug_slint.slint as_weak_callback.rs safe_callback_host.rs github-workflows/slint-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS slint-kit-selfcheck"
