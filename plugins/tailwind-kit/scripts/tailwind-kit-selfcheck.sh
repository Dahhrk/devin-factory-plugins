#!/usr/bin/env bash
# Prove tailwind-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/tailwind-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/tailwind-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/tailwind-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env TAILWIND_RG_BUDGET_MS=1 bash "$HERE/tailwind-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-tw env TAILWIND_TAILWIND_CONFIG_ONLY=1 bash "$HERE/tailwind-tailwind-gate.sh" "$ROOT/testdata/good" &
probe tw-missing env TAILWIND_TAILWIND_CONFIG_ONLY=1 bash "$HERE/tailwind-tailwind-gate.sh" "$ROOT/testdata/tailwind-missing" &
probe tw-weak env TAILWIND_TAILWIND_CONFIG_ONLY=1 bash "$HERE/tailwind-tailwind-gate.sh" "$ROOT/testdata/tailwind-weak" &
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
check_fail tight-hot "hotpath budget fails when TAILWIND_RG_BUDGET_MS=1"
check_pass good-tw "tailwind passes on good (config)"
check_fail tw-missing "tailwind fails without wiring"
check_fail tw-weak "tailwind fails without package.json tailwindcss / config / CI"

require_grep "$HERE/tailwind-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/tailwind-hotpath-gate.sh" 'TAILWIND_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/tailwind-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.css" '@apply' "bad fixture encodes @apply"
require_grep "$ROOT/testdata/bad/smells.html" '\[[0-9#]' "bad fixture encodes arbitrary values"
require_grep "$ROOT/testdata/bad/tailwind.config.js" 'safelist' "bad fixture encodes safelist"
require_grep "$ROOT/testdata/bad/tailwind.config.js" 'content: \[\]' "bad fixture encodes empty content"
require_grep "$ROOT/testdata/bad/smells.html" "className = 'bg-' \+" "bad fixture encodes dynamic class concat"
require_grep "$ROOT/testdata/good/ok.html" 'tailwind-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/package.json" '"tailwindcss"' "good package.json encodes tailwindcss dep"
require_grep "$ROOT/templates/utility_over_apply.html" 'class=' "utility_over_apply template encodes utilities"
require_grep "$ROOT/templates/design_tokens_not_arbitrary.html" 'bg-red-500' "design_tokens template encodes tokens"
require_grep "$ROOT/templates/content_paths_complete.js" 'content:' "content_paths_complete template encodes content"
require_grep "$ROOT/templates/no_safelist_abuse.js" 'content:' "no_safelist_abuse template encodes content without safelist"

for f in utility_over_apply.html design_tokens_not_arbitrary.html content_paths_complete.js no_safelist_abuse.js github-workflows/tailwind-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS tailwind-kit-selfcheck"
