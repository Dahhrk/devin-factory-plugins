#!/usr/bin/env bash
# Prove cmake-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/cmake-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/cmake-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/cmake-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env CMAKE_RG_BUDGET_MS=1 bash "$HERE/cmake-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-cmake env CMAKE_CMAKE_CONFIG_ONLY=1 bash "$HERE/cmake-cmake-gate.sh" "$ROOT/testdata/good" &
probe cmake-missing env CMAKE_CMAKE_CONFIG_ONLY=1 bash "$HERE/cmake-cmake-gate.sh" "$ROOT/testdata/cmake-missing" &
probe cmake-weak env CMAKE_CMAKE_CONFIG_ONLY=1 bash "$HERE/cmake-cmake-gate.sh" "$ROOT/testdata/cmake-weak" &
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
check_fail tight-hot "hotpath budget fails when CMAKE_RG_BUDGET_MS=1"
check_pass good-cmake "cmake passes on good (config)"
check_fail cmake-missing "cmake fails without wiring"
check_fail cmake-weak "cmake fails without CMakeLists instructions / dep / CI"

require_grep "$HERE/cmake-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/cmake-hotpath-gate.sh" 'CMAKE_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/cmake-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.cmake" 'file\(DOWNLOAD' "bad fixture encodes DOWNLOAD"
require_grep "$ROOT/testdata/bad/smells.cmake" 'execute_process' "bad fixture encodes execute_process"
require_grep "$ROOT/testdata/bad/smells.cmake" 'file\(GLOB' "bad fixture encodes GLOB"
require_grep "$ROOT/testdata/bad/smells.cmake" 'CACHE.*FORCE|FORCE' "bad fixture encodes CACHE FORCE"
require_grep "$ROOT/testdata/bad/smells.cmake" 'include\(\$\{' "bad fixture encodes include(\${"
require_grep "$ROOT/testdata/good/ok.cmake" 'EXPECTED_HASH' "good fixture encodes EXPECTED_HASH"
require_grep "$ROOT/testdata/good/ok.cmake" 'RESULT_VARIABLE' "good fixture encodes RESULT_VARIABLE"
require_grep "$ROOT/testdata/good/ok.cmake" 'CACHE BOOL' "good fixture encodes CACHE without FORCE"
require_grep "$ROOT/testdata/good/ok.cmake" 'include\(CheckCXXCompilerFlag\)' "good fixture encodes static include"
require_grep "$ROOT/testdata/good/CMakeLists.txt" 'add_library' "good CMakeLists encodes add_library"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'cmake' "good CI encodes cmake"
require_grep "$ROOT/templates/download_expected_hash.cmake" 'EXPECTED_HASH' "download_expected_hash template encodes EXPECTED_HASH"
require_grep "$ROOT/templates/execute_process_checked.cmake" 'RESULT_VARIABLE' "execute_process_checked template encodes RESULT_VARIABLE"
require_grep "$ROOT/templates/explicit_sources.cmake" 'add_library\(app' "explicit_sources template encodes explicit sources"
require_grep "$ROOT/templates/cache_no_force.cmake" 'CACHE BOOL' "cache_no_force template encodes CACHE"
require_grep "$ROOT/templates/trusted_static_include.cmake" 'include\(CheckCXXCompilerFlag\)' "trusted_static_include template encodes static include"

for f in download_expected_hash.cmake execute_process_checked.cmake explicit_sources.cmake cache_no_force.cmake trusted_static_include.cmake github-workflows/cmake-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS cmake-kit-selfcheck"
