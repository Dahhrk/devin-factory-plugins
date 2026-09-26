#!/usr/bin/env bash
# Prove just-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/just-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/just-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/just-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env JUST_RG_BUDGET_MS=1 bash "$HERE/just-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-just env JUST_JUST_CONFIG_ONLY=1 bash "$HERE/just-just-gate.sh" "$ROOT/testdata/good" &
probe just-missing env JUST_JUST_CONFIG_ONLY=1 bash "$HERE/just-just-gate.sh" "$ROOT/testdata/just-missing" &
probe just-weak env JUST_JUST_CONFIG_ONLY=1 bash "$HERE/just-just-gate.sh" "$ROOT/testdata/just-weak" &
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
check_fail tight-hot "hotpath budget fails when JUST_RG_BUDGET_MS=1"
check_pass good-just "just passes on good (config)"
check_fail just-missing "just fails without wiring"
check_fail just-weak "just fails without justfile instructions / dep / CI"

require_grep "$HERE/just-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/just-hotpath-gate.sh" 'JUST_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/just-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.just" '\[script\]' "bad fixture encodes [script]"
require_grep "$ROOT/testdata/bad/smells.just" '#!/usr/bin/env' "bad fixture encodes shebang"
require_grep "$ROOT/testdata/bad/smells.just" 'set dotenv-load' "bad fixture encodes dotenv-load"
require_grep "$ROOT/testdata/bad/smells.just" 'export API_KEY|export SECRET' "bad fixture encodes export secret"
require_grep "$ROOT/testdata/bad/smells.just" "import '\\{\\{|mod .*'~/" "bad fixture encodes untrusted import/mod"
require_grep "$ROOT/testdata/bad/smells.just" 'curl.*\|.*bash|curl.*\| bash' "bad fixture encodes curl|bash"
require_grep "$ROOT/testdata/good/justfile" 'build:' "good fixture encodes recipe"
require_grep "$ROOT/testdata/good/ok.just" "import 'rules\\.just'" "good fixture encodes static import"
require_grep "$ROOT/testdata/good/ok.just" 'VERSION :=' "good fixture encodes explicit VERSION"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'just' "good CI encodes just"
require_grep "$ROOT/templates/no_script_shebang.just" 'build:' "no_script_shebang template encodes recipe"
require_grep "$ROOT/templates/no_dotenv_secrets.just" 'serve:' "no_dotenv_secrets template encodes serve"
require_grep "$ROOT/templates/no_export_secrets.just" 'test:' "no_export_secrets template encodes test"
require_grep "$ROOT/templates/trusted_static_import.just" "import 'rules\\.just'" "trusted_static_import template encodes static import"
require_grep "$ROOT/templates/no_curl_bash.just" 'install\.sh' "no_curl_bash template encodes install.sh"

for f in no_script_shebang.just no_dotenv_secrets.just no_export_secrets.just trusted_static_import.just no_curl_bash.just github-workflows/just-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS just-kit-selfcheck"
