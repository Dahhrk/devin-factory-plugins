#!/usr/bin/env bash
# Tier 0.5b: go vet (PSR: go vet).
# Usage: bash scripts/go-vet-gate.sh [root] [./pkg/... ...]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true
PATS=("${@:-./...}")
export GOTOOLCHAIN="${GOTOOLCHAIN:-auto}"
go vet "${PATS[@]}"
echo "PASS go-vet-gate (${PATS[*]})"
