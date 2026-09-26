#!/usr/bin/env bash
# Tier 0.5: shfmt clean (PSR: one formatter = shfmt).
# Usage: bash scripts/sh-fmt-gate.sh [root] [path ...]
# Flags aligned with templates: -i 2 -ci -bn
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
else
  TARGETS=(.)
fi

if ! command -v shfmt >/dev/null 2>&1; then
  echo "FAIL: shfmt not on PATH (install mvdan.cc/sh/v3/cmd/shfmt)"
  exit 1
fi

mapfile -t files < <(
  find "${TARGETS[@]}" \( -name '*.sh' -o -name '*.bash' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | sort || true
)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no .sh/.bash files under ${TARGETS[*]}"
  exit 1
fi

DIFF="$(mktemp)"
trap 'rm -f "$DIFF"' EXIT
# -d: diff only; non-zero if reformatting needed
set +e
shfmt -d -i 2 -ci -bn "${files[@]}" >"$DIFF" 2>&1
rc=$?
set -e
if [[ "$rc" -ne 0 ]]; then
  echo "FAIL: shfmt needed on:"
  cat "$DIFF"
  exit 1
fi
echo "PASS sh-fmt-gate (${#files[@]} files)"
