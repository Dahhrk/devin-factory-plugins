#!/usr/bin/env bash
# Prove rust-kit gates discriminate fixtures (pack maturity).
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

expect_fail bad-rg "rg fails on bad" bash "$HERE/rust-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/rust-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/rust-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when RUST_RG_BUDGET_MS=1" env RUST_RG_BUDGET_MS=1 bash "$HERE/rust-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good (config)" env RUST_FMT_CONFIG_ONLY=1 bash "$HERE/rust-fmt-gate.sh" "$ROOT/testdata/good" &
expect_fail fmt-missing "fmt fails without rustfmt.toml" env RUST_FMT_CONFIG_ONLY=1 bash "$HERE/rust-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
wait

expect_pass good-clippy "clippy passes on good wiring" env RUST_CLIPPY_CONFIG_ONLY=1 bash "$HERE/rust-clippy-gate.sh" "$ROOT/testdata/good"
expect_fail clippy-missing "clippy fails without wiring" env RUST_CLIPPY_CONFIG_ONLY=1 bash "$HERE/rust-clippy-gate.sh" "$ROOT/testdata/clippy-missing"
expect_pass good-testci "test-ci passes with workflow cargo test" bash "$HERE/rust-test-ci-gate.sh" "$ROOT/testdata/good"
expect_fail testci-missing "test-ci fails without cargo test wiring" bash "$HERE/rust-test-ci-gate.sh" "$ROOT/testdata/test-ci-missing"

require_grep "$HERE/rust-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/rust-hotpath-gate.sh" 'RUST_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/rust-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.rs" '\bunsafe\b' "bad fixture encodes unsafe"
require_grep "$ROOT/testdata/bad/smell.rs" 'transmute' "bad fixture encodes transmute"
require_grep "$ROOT/testdata/bad/smell.rs" 'extern "C"' "bad fixture encodes extern C"
require_grep "$ROOT/testdata/bad/smell.rs" 'todo!' "bad fixture encodes todo!"
require_grep "$ROOT/testdata/bad/smell.rs" 'no_mangle' "bad fixture encodes no_mangle"
require_grep "$ROOT/testdata/good/smell_free.rs" 'rust-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/unsafe_boundary.rs" 'SAFETY' "unsafe_boundary template encodes SAFETY"
require_grep "$ROOT/templates/ffi_extern.rs" 'extern "C"' "ffi_extern template encodes extern C"
require_grep "$ROOT/templates/clippy/clippy.toml" 'cognitive-complexity' "clippy template present"

for f in unsafe_boundary.rs ffi_extern.rs rustfmt.toml clippy/clippy.toml github-workflows/rust-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS rust-kit-selfcheck"
