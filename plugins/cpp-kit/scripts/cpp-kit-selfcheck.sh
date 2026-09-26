#!/usr/bin/env bash
# Prove cpp-kit gates discriminate fixtures (pack maturity).
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

expect_fail bad-rg "rg fails on bad" bash "$HERE/cpp-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/cpp-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/cpp-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when CPP_RG_BUDGET_MS=1" env CPP_RG_BUDGET_MS=1 bash "$HERE/cpp-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good (config)" env CPP_FMT_CONFIG_ONLY=1 bash "$HERE/cpp-fmt-gate.sh" "$ROOT/testdata/good" &
expect_fail fmt-missing "fmt fails without .clang-format" env CPP_FMT_CONFIG_ONLY=1 bash "$HERE/cpp-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
wait

expect_pass good-warn "warn passes with -Wall -Wextra" bash "$HERE/cpp-warn-gate.sh" "$ROOT/testdata/good"
expect_fail warn-missing "warn fails without -Wall -Wextra" bash "$HERE/cpp-warn-gate.sh" "$ROOT/testdata/warn-missing"
expect_pass good-tidy "tidy-ci passes with .clang-tidy" bash "$HERE/cpp-tidy-ci-gate.sh" "$ROOT/testdata/good"
expect_fail tidy-missing "tidy-ci fails without clang-tidy wiring" bash "$HERE/cpp-tidy-ci-gate.sh" "$ROOT/testdata/tidy-missing"

require_grep "$HERE/cpp-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/cpp-hotpath-gate.sh" 'CPP_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/cpp-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.cpp" 'new ' "bad fixture encodes raw new"
require_grep "$ROOT/testdata/bad/smell.cpp" 'delete' "bad fixture encodes raw delete"
require_grep "$ROOT/testdata/bad/smell.cpp" 'sprintf' "bad fixture encodes sprintf"
require_grep "$ROOT/testdata/bad/smell.cpp" '(int)' "bad fixture encodes C-style cast"
require_grep "$ROOT/testdata/good/ok.cpp" 'cpp-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/unique_ptr_new.cpp" 'unique_ptr' "unique_ptr_new template encodes unique_ptr"
require_grep "$ROOT/templates/static_cast.cpp" 'static_cast' "static_cast template encodes static_cast"

for f in unique_ptr_new.cpp static_cast.cpp clang-format clang-tidy/clang-tidy github-workflows/cpp-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS cpp-kit-selfcheck"
