#!/usr/bin/env bash
# Tier 1: require explicit failure mode in product shell scripts (PSR: set -euo pipefail).
# Each *.sh / *.bash must contain set -euo pipefail (or set -eu + set -o pipefail).
# Usage: bash scripts/sh-strict-gate.sh [root] [path ...]
# Escape: SH_STRICT_GATE_SKIP=1 for tiny sourced fragments documented as library-only.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if [[ "${SH_STRICT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS sh-strict-gate (skipped via SH_STRICT_GATE_SKIP=1)"
  exit 0
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
else
  TARGETS=(.)
fi

mapfile -t files < <(
  find "${TARGETS[@]}" \( -name '*.sh' -o -name '*.bash' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' \
    -not -path '*/testdata/*' -not -path '*/fixtures/*' 2>/dev/null | sort || true
)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no .sh/.bash files under ${TARGETS[*]}"
  exit 1
fi

fail=0
for f in "${files[@]}"; do
  if rg -q 'set[[:space:]]+-euo[[:space:]]+pipefail|set[[:space:]]+-eo[[:space:]]+pipefail' "$f"; then
    continue
  fi
  # Accept split form: set -eu (or set -e + set -u) AND set -o pipefail
  if rg -q 'set[[:space:]]+-[a-zA-Z]*e[a-zA-Z]*u|set[[:space:]]+-eu\b|set[[:space:]]+-e\b' "$f" \
    && rg -q 'set[[:space:]]+-o[[:space:]]+pipefail' "$f"; then
    continue
  fi
  echo "FAIL: $f missing set -euo pipefail (PSR: explicit failure)"
  fail=1
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS sh-strict-gate (${#files[@]} files)"
