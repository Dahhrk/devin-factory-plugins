#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Dockerfile smells (portable regex bar).
# PSR: no ADD vs COPY secrets; no :latest tags; no apt without cleanup;
# no USER root late; no secrets in ARG/ENV; no curl|bash.
# Language-farm. Product docker build --check / BuildKit linter remains authoritative;
# this gate is the portable rg bar for Dockerfile trust smells.
#
# Usage: bash scripts/dockerfile-rg-gate.sh [root] [path ...]
# Default scan: DOCKERFILE_RG_SRC or . Escape hatch: dockerfile-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers Dockerfile* / *.Dockerfile / Containerfile* /
# docker-compose*.{yml,yaml}.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for dockerfile-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${DOCKERFILE_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${DOCKERFILE_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
IDS=(add_vs_copy_secrets latest_tag apt_no_cleanup user_root_late secrets_arg_env curl_bash)
SCAN_PATS=(
  '(?i)^\s*ADD\s+(?:--[^\s]+\s+)*(?:https?://|ftp://|\S*(?:secret|password|credential|token|id_rsa|\.pem|\.key)\S*)'
  '(?i)^\s*FROM\s+(?:--platform=\S+\s+)*\S+:latest\b'
  '(?i)(?:^|\s)(?:apt-get|apt)\s+(?:update|install)\b(?![^\n]*rm\s+-rf\s+/var/lib/apt)'
  '(?i)^\s*USER\s+root\b'
  '(?i)^\s*(?:ARG|ENV)\s+(?:[A-Za-z0-9_]+=)?[A-Za-z0-9_]*(?:SECRET|PASSWORD|TOKEN|API[_-]?KEY|PASSPHRASE|CREDENTIAL|(?<![A-Za-z])AUTH(?![A-Za-z_])|PRIVATE[_-]?KEY|ACCESS[_-]?KEY|GIT[_-]?KEY)[A-Za-z0-9_]*\b'
  '(?i)(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)
CLASS_PATS=(
  '(?i):[0-9]+:\s*ADD\s+(?:--[^\s]+\s+)*(?:https?://|ftp://|\S*(?:secret|password|credential|token|id_rsa|\.pem|\.key)\S*)'
  '(?i):[0-9]+:\s*FROM\s+(?:--platform=\S+\s+)*\S+:latest\b'
  '(?i)(?:apt-get|apt)\s+(?:update|install)\b(?![^\n]*rm\s+-rf\s+/var/lib/apt)'
  '(?i):[0-9]+:\s*USER\s+root\b'
  '(?i):[0-9]+:\s*(?:ARG|ENV)\s+(?:[A-Za-z0-9_]+=)?[A-Za-z0-9_]*(?:SECRET|PASSWORD|TOKEN|API[_-]?KEY|PASSPHRASE|CREDENTIAL|(?<![A-Za-z])AUTH(?![A-Za-z_])|PRIVATE[_-]?KEY|ACCESS[_-]?KEY|GIT[_-]?KEY)[A-Za-z0-9_]*\b'
  '(?i)(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)

MSGS=(
  'ADD vs COPY secrets banned (ADD http(s)/ftp or ADD secret/password/credential/token/id_rsa/.pem/.key; prefer COPY + --mount=type=secret; dockerfile-rg-allow with rationale)'
  ':latest tag banned (FROM ...:latest; prefer digest or immutable tag; dockerfile-rg-allow with rationale)'
  'apt without cleanup banned (apt-get/apt update|install without rm -rf /var/lib/apt on same RUN; dockerfile-rg-allow with rationale)'
  'USER root late banned (USER root; prefer non-root USER before final process; dockerfile-rg-allow with rationale)'
  'secrets in ARG/ENV banned (ARG/ENV *SECRET*|*PASSWORD*|*TOKEN*|*APIKEY*|*PASSPHRASE*|*CREDENTIAL*|*AUTH*|*KEY*; prefer BuildKit secret mounts; dockerfile-rg-allow with rationale)'
  'curl|bash banned (curl|bash / wget|sh pipe-to-shell; prefer COPY install script + checksum; dockerfile-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob 'Dockerfile' --glob 'Dockerfile.*' --glob '*.Dockerfile' --glob 'Containerfile' --glob 'Containerfile.*'
  --glob 'docker-compose.yml' --glob 'docker-compose.yaml' --glob 'docker-compose.*.yml' --glob 'docker-compose.*.yaml'
  --glob '**/Dockerfile' --glob '**/Dockerfile.*' --glob '**/*.Dockerfile' --glob '**/Containerfile' --glob '**/Containerfile.*'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and hash/line-comment-only hits (# Dockerfile comments).
  rg -v 'dockerfile-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(#|//)' >"$FILT" || true
else
  : >"$FILT"
fi

report_fail() {
  echo "FAIL: $1"
  head -40 "$2"
  local n; n=$(wc -l <"$2" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
}

classify_one() {
  local i="$1" id="${IDS[$i]}" cpat="${CLASS_PATS[$i]}"
  local hitfile="$TMPDIR_GATE/hit.$id" rcfile="$TMPDIR_GATE/rc.$id"
  : >"$hitfile"
  rg -P -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
  if [[ -s "$hitfile" ]]; then echo 1 >"$rcfile"; else echo 0 >"$rcfile"; fi
}

if [[ -s "$FILT" ]]; then
  pids=()
  for i in "${!IDS[@]}"; do classify_one "$i" & pids+=($!); done
  for pid in "${pids[@]}"; do wait "$pid" || true; done
  for i in "${!IDS[@]}"; do
    if [[ "$(cat "$TMPDIR_GATE/rc.${IDS[$i]}")" != "0" ]]; then
      report_fail "${MSGS[$i]}" "$TMPDIR_GATE/hit.${IDS[$i]}"
      fail=1
    fi
  done
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS dockerfile-rg-gate (${TARGETS[*]}, single-walk)"
