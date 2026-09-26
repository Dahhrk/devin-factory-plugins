#!/usr/bin/env bash
# Tier 1: require docker / Dockerfile toolchain wiring (PSR Dockerfile language-farm).
# Live `docker version` when resolvable unless DOCKERFILE_DOCKER_CONFIG_ONLY=1.
# Portable bar: Dockerfile / Containerfile / compose / CI docker build.
# Escape: DOCKERFILE_DOCKER_GATE_SKIP=1.
# Usage: bash scripts/dockerfile-docker-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${DOCKERFILE_DOCKER_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS dockerfile-docker-gate (skipped via DOCKERFILE_DOCKER_GATE_SKIP=1)"
  exit 0
fi

mapfile -t df_files < <(find . \( \
  -name 'Dockerfile' -o -name 'Dockerfile.*' -o -name '*.Dockerfile' \
  -o -name 'Containerfile' -o -name 'Containerfile.*' \
  -o -name 'docker-compose.yml' -o -name 'docker-compose.yaml' \
  -o -name 'docker-compose.*.yml' -o -name 'docker-compose.*.yaml' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' \
  2>/dev/null | sort || true)
if [[ ${#df_files[@]} -eq 0 ]]; then
  echo "FAIL: no Dockerfile / Containerfile / compose under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real Dockerfile instruction anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)^\s*(FROM|COPY|RUN|CMD|ENTRYPOINT|USER|WORKDIR)\b'

if rg -qP --glob 'Dockerfile' --glob 'Dockerfile.*' --glob '*.Dockerfile' --glob 'Containerfile' --glob 'Containerfile.*' \
  --glob '!**/.git/**' --glob '!**/vendor/**' "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="dockerfile-instructions"
fi

if [[ "$has_file_cfg" -eq 0 ]]; then
  for candidate in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
    if [[ -f "$candidate" ]] && rg -qiP '^\s*(services|image|build)\b' "$candidate" 2>/dev/null; then
      has_file_cfg=1
      CFG="$candidate"
      break
    fi
  done
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])docker(\s+build|\s+compose|file)|dockerfile-lint|buildx|buildkit' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: Dockerfile instructions / compose, or CI that names docker.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no docker wiring (Dockerfile instructions / compose / CI; PSR: Docker toolchain)"
  exit 1
fi

if [[ "${DOCKERFILE_DOCKER_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS dockerfile-docker-gate ($ROOT, config-only, ${#df_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v docker >/dev/null 2>&1; then
  set +e
  docker version >/tmp/dockerfile-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/dockerfile-gate-ver.$$.out"
    echo "PASS dockerfile-docker-gate ($ROOT, live docker, ${#df_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/dockerfile-gate-ver.$$.out"
fi

echo "PASS dockerfile-docker-gate ($ROOT, config-only fallback, ${#df_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
