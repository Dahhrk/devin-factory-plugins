#!/usr/bin/env bash
# Prove nix-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/nix-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/nix-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/nix-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env NIX_RG_BUDGET_MS=1 bash "$HERE/nix-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-nix env NIX_NIX_CONFIG_ONLY=1 bash "$HERE/nix-nix-gate.sh" "$ROOT/testdata/good" &
probe nix-missing env NIX_NIX_CONFIG_ONLY=1 bash "$HERE/nix-nix-gate.sh" "$ROOT/testdata/nix-missing" &
probe nix-weak env NIX_NIX_CONFIG_ONLY=1 bash "$HERE/nix-nix-gate.sh" "$ROOT/testdata/nix-weak" &
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
check_fail tight-hot "hotpath budget fails when NIX_RG_BUDGET_MS=1"
check_pass good-nix "nix passes on good (config)"
check_fail nix-missing "nix fails without wiring"
check_fail nix-weak "nix fails without nix instructions / dep / CI"

require_grep "$HERE/nix-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/nix-hotpath-gate.sh" 'NIX_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/nix-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/default.nix" 'fetchurl \{ url' "bad fixture encodes fetchurl without hash"
require_grep "$ROOT/testdata/bad/default.nix" 'builtins\.exec' "bad fixture encodes builtins.exec"
require_grep "$ROOT/testdata/bad/default.nix" 'import \(pkgs\.fetchFromGitHub' "bad fixture encodes IFD import(fetch)"
require_grep "$ROOT/testdata/bad/default.nix" 'builtins\.getEnv' "bad fixture encodes getEnv"
require_grep "$ROOT/testdata/bad/default.nix" 'chmod 777' "bad fixture encodes chmod 777"
require_grep "$ROOT/testdata/bad/default.nix" 'curl.*\|.*bash|curl.*\| bash' "bad fixture encodes curl|bash"
require_grep "$ROOT/testdata/good/default.nix" 'hash = "sha256-' "good fixture encodes hashed fetchurl"
require_grep "$ROOT/testdata/good/default.nix" 'install -m 755' "good fixture encodes non-world-writable install"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'nix' "good CI encodes nix"
require_grep "$ROOT/templates/fetchurl_with_hash.nix" 'hash = "sha256-' "fetchurl_with_hash template encodes hash"
require_grep "$ROOT/templates/no_exec_ifd.nix" 'callPackage' "no_exec_ifd template encodes callPackage"
require_grep "$ROOT/templates/no_getEnv.nix" 'config\.feature' "no_getEnv template encodes explicit config"
require_grep "$ROOT/templates/no_world_writable.nix" 'install -m 755' "no_world_writable template encodes 755"
require_grep "$ROOT/templates/no_curl_bash.nix" 'install\.sh' "no_curl_bash template encodes install.sh"

for f in fetchurl_with_hash.nix no_exec_ifd.nix no_getEnv.nix no_world_writable.nix no_curl_bash.nix github-workflows/nix-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS nix-kit-selfcheck"
