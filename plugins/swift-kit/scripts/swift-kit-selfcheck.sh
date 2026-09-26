#!/usr/bin/env bash
# Prove swift-kit gates discriminate fixtures (pack maturity).
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

# Parallel probes (fail aggregation after wait; subshell fail= is discarded).
probe bad-rg bash "$HERE/swift-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/swift-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/swift-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env SWIFT_RG_BUDGET_MS=1 bash "$HERE/swift-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-fmt env SWIFT_FMT_CONFIG_ONLY=1 bash "$HERE/swift-fmt-gate.sh" "$ROOT/testdata/good" &
probe fmt-missing env SWIFT_FMT_CONFIG_ONLY=1 bash "$HERE/swift-fmt-gate.sh" "$ROOT/testdata/fmt-missing" &
probe good-lint bash "$HERE/swift-lint-gate.sh" "$ROOT/testdata/good" &
probe lint-missing bash "$HERE/swift-lint-gate.sh" "$ROOT/testdata/lint-missing" &
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
check_fail tight-hot "hotpath budget fails when SWIFT_RG_BUDGET_MS=1"
check_pass good-fmt "fmt passes on good (config)"
check_fail fmt-missing "fmt fails without swift-format wiring"
check_pass good-lint "lint passes on good"
check_fail lint-missing "lint fails without SwiftLint"

require_grep "$HERE/swift-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/swift-hotpath-gate.sh" 'SWIFT_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/swift-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/Smell.swift" 'try!' "bad fixture encodes try!"
require_grep "$ROOT/testdata/bad/Smell.swift" 'UnsafeMutablePointer|withUnsafe' "bad fixture encodes unsafe pointer"
require_grep "$ROOT/testdata/bad/Smell.swift" '!' "bad fixture encodes force unwrap"
require_grep "$ROOT/testdata/good/Sources/Ok.swift" 'swift-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/templates/optional_bind.swift" 'guard let|if let|\?\?' "optional_bind template encodes bind"
require_grep "$ROOT/templates/safe_pointer.swift" 'withUnsafe|Unsafe|swift-rg-allow' "safe_pointer template encodes named boundary"

for f in optional_bind.swift safe_pointer.swift .swift-format .swiftlint.yml github-workflows/swift-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS swift-kit-selfcheck"
