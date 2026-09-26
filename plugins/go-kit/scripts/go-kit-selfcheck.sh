#!/usr/bin/env bash
# Prove go-kit gates discriminate fixtures (pack maturity).
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

expect_fail bad-rg "rg fails on bad" bash "$HERE/go-rg-gate.sh" "$ROOT/testdata/bad" . &
expect_pass good-rg "rg passes on good" bash "$HERE/go-rg-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-hot "hotpath budget passes on good" bash "$HERE/go-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_fail tight-hot "hotpath budget fails when GO_RG_BUDGET_MS=1" env GO_RG_BUDGET_MS=1 bash "$HERE/go-hotpath-gate.sh" "$ROOT/testdata/good" . &
expect_pass good-fmt "fmt passes on good" bash "$HERE/go-fmt-gate.sh" "$ROOT/testdata/good" . &
wait

# race-ci against a fake root with -race in Makefile
TMP=$(mktemp -d)
echo 'test: ; go test -race ./...' >"$TMP/Makefile"
expect_pass race-ci "race-ci passes with Makefile -race" bash "$HERE/go-race-ci-gate.sh" "$TMP"
rm -rf "$TMP"

TMP=$(mktemp -d)
expect_fail race-missing "race-ci fails without -race" bash "$HERE/go-race-ci-gate.sh" "$TMP"
rm -rf "$TMP"

# golangci gate against pack template copy
TMP=$(mktemp -d)
cp "$ROOT/templates/golangci/golangci.yml" "$TMP/.golangci.yml"
expect_pass golangci "golangci-gate passes on pack template" bash "$HERE/go-golangci-gate.sh" "$TMP"
rm -rf "$TMP"

TMP=$(mktemp -d)
expect_fail golangci-missing "golangci-gate fails when missing" bash "$HERE/go-golangci-gate.sh" "$TMP"
rm -rf "$TMP"

require_grep "$HERE/go-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/go-hotpath-gate.sh" 'GO_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/go-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.go" 'var Hook' "bad fixture encodes func hook"
require_grep "$ROOT/testdata/bad/smell.go" '[[:space:]]go[[:space:]]' "bad fixture encodes bare go"
require_grep "$ROOT/testdata/bad/smell.go" 'ioutil\.' "bad fixture encodes ioutil"
require_grep "$ROOT/testdata/bad/smell.go" 'panic\(' "bad fixture encodes panic"
require_grep "$ROOT/testdata/bad/smell.go" 'errgroup\.WithContext' "bad fixture encodes errgroup Background"
require_grep "$ROOT/testdata/good/ok.go" 'go-rg-allow' "good fixture encodes allow on named boundary"
require_grep "$ROOT/templates/ctx_errgroup.go" 'errgroup' "ctx_errgroup template encodes errgroup"
require_grep "$ROOT/templates/http_close.go" 'Body\.Close' "http_close template encodes Body.Close"
require_grep "$ROOT/templates/golangci/golangci.yml" 'bodyclose' "golangci template encodes bodyclose"
require_grep "$ROOT/templates/golangci/golangci.yml" 'errcheck' "golangci template encodes errcheck"

for f in ctx_errgroup.go http_close.go golangci/golangci.yml github-workflows/go-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS go-kit-selfcheck"
