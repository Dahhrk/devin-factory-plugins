#!/usr/bin/env bash
# Prove vite-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/vite-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/vite-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/vite-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env VITE_RG_BUDGET_MS=1 bash "$HERE/vite-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-vite env VITE_VITE_CONFIG_ONLY=1 bash "$HERE/vite-vite-gate.sh" "$ROOT/testdata/good" &
probe vite-missing env VITE_VITE_CONFIG_ONLY=1 bash "$HERE/vite-vite-gate.sh" "$ROOT/testdata/vite-missing" &
probe vite-weak env VITE_VITE_CONFIG_ONLY=1 bash "$HERE/vite-vite-gate.sh" "$ROOT/testdata/vite-weak" &
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
check_fail tight-hot "hotpath budget fails when VITE_RG_BUDGET_MS=1"
check_pass good-vite "vite passes on good (config)"
check_fail vite-missing "vite fails without wiring"
check_fail vite-weak "vite fails without package.json vite / CI"

require_grep "$HERE/vite-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/vite-hotpath-gate.sh" 'VITE_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/vite-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/vite.config.ts" 'strict: false' "bad fixture encodes strict:false"
require_grep "$ROOT/testdata/bad/vite.config.ts" "allow: \\['\\.\\.'\\]" "bad fixture encodes allow parent"
require_grep "$ROOT/testdata/bad/vite.config.ts" "loadEnv" "bad fixture encodes loadEnv"
require_grep "$ROOT/testdata/good/vite.config.ts" 'vite-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/package.json" '"vite"' "good package.json encodes vite dep"
require_grep "$ROOT/templates/fs_strict_default.ts" 'strict: true' "fs_strict_default template encodes strict:true"
require_grep "$ROOT/templates/fs_allow_workspace.ts" 'searchForWorkspaceRoot' "fs_allow_workspace template encodes searchForWorkspaceRoot"
require_grep "$ROOT/templates/loadenv_vite_prefix.ts" "loadEnv" "loadenv_vite_prefix template encodes loadEnv"

for f in fs_strict_default.ts fs_allow_workspace.ts loadenv_vite_prefix.ts github-workflows/vite-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS vite-kit-selfcheck"
