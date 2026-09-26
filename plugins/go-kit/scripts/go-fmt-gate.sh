#!/usr/bin/env bash
# Tier 0.5a: gofmt clean (PSR: gofmt).
# Usage: bash scripts/go-fmt-gate.sh [root] [path ...]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true
TARGETS=("${@:-.}")
mapfile -t files < <(find "${TARGETS[@]}" -name '*.go' -not -path '*/vendor/*' -not -path '*/.git/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no .go files under ${TARGETS[*]}"
  exit 1
fi
bad=$(gofmt -l "${files[@]}" || true)
if [[ -n "$bad" ]]; then
  echo "FAIL: gofmt needed on:"
  echo "$bad"
  exit 1
fi
echo "PASS go-fmt-gate (${#files[@]} files)"
