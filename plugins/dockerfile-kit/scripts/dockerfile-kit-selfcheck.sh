#!/usr/bin/env bash
# Prove dockerfile-kit gates discriminate fixtures (pack maturity).
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

probe bad-rg bash "$HERE/dockerfile-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/dockerfile-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/dockerfile-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env DOCKERFILE_RG_BUDGET_MS=1 bash "$HERE/dockerfile-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-docker env DOCKERFILE_DOCKER_CONFIG_ONLY=1 bash "$HERE/dockerfile-docker-gate.sh" "$ROOT/testdata/good" &
probe docker-missing env DOCKERFILE_DOCKER_CONFIG_ONLY=1 bash "$HERE/dockerfile-docker-gate.sh" "$ROOT/testdata/docker-missing" &
probe docker-weak env DOCKERFILE_DOCKER_CONFIG_ONLY=1 bash "$HERE/dockerfile-docker-gate.sh" "$ROOT/testdata/docker-weak" &
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
check_fail tight-hot "hotpath budget fails when DOCKERFILE_RG_BUDGET_MS=1"
check_pass good-docker "docker passes on good (config)"
check_fail docker-missing "docker fails without wiring"
check_fail docker-weak "docker fails without Dockerfile instructions / dep / CI"

require_grep "$HERE/dockerfile-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/dockerfile-hotpath-gate.sh" 'DOCKERFILE_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/dockerfile-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smells.Dockerfile" 'ADD' "bad fixture encodes ADD"
require_grep "$ROOT/testdata/bad/smells.Dockerfile" ':latest' "bad fixture encodes :latest"
require_grep "$ROOT/testdata/bad/smells.Dockerfile" 'apt-get' "bad fixture encodes apt-get"
require_grep "$ROOT/testdata/bad/smells.Dockerfile" 'USER root' "bad fixture encodes USER root"
require_grep "$ROOT/testdata/bad/smells.Dockerfile" 'SECRET|PASSWORD' "bad fixture encodes ARG/ENV secrets"
require_grep "$ROOT/testdata/bad/smells.Dockerfile" 'curl.*\|.*bash|curl .*\|| bash' "bad fixture encodes curl|bash"
require_grep "$ROOT/testdata/good/ok.Dockerfile" 'rm -rf /var/lib/apt' "good fixture encodes apt cleanup"
require_grep "$ROOT/testdata/good/ok.Dockerfile" 'USER nobody' "good fixture encodes non-root USER"
require_grep "$ROOT/testdata/good/ok.Dockerfile" 'mount=type=secret' "good fixture encodes secret mount"
require_grep "$ROOT/testdata/good/.github/workflows/ci.yml" 'docker build' "good CI encodes docker build"
require_grep "$ROOT/templates/copy_not_add.Dockerfile" 'COPY' "copy_not_add template encodes COPY"
require_grep "$ROOT/templates/pinned_from.Dockerfile" 'FROM ' "pinned_from template encodes FROM"
require_grep "$ROOT/templates/apt_cleanup.Dockerfile" '/var/lib/apt' "apt_cleanup template encodes cleanup"
require_grep "$ROOT/templates/nonroot_user.Dockerfile" 'USER appuser' "nonroot_user template encodes USER"
require_grep "$ROOT/templates/secret_mount.Dockerfile" 'type=secret' "secret_mount template encodes secret mount"
require_grep "$ROOT/templates/no_curl_bash.Dockerfile" 'COPY scripts/install.sh' "no_curl_bash template encodes COPY install script"

for f in copy_not_add.Dockerfile pinned_from.Dockerfile apt_cleanup.Dockerfile nonroot_user.Dockerfile secret_mount.Dockerfile no_curl_bash.Dockerfile github-workflows/dockerfile-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS dockerfile-kit-selfcheck"
