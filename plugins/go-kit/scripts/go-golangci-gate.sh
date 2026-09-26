#!/usr/bin/env bash
# Tier 1b: require product .golangci.yml to enable bodyclose + errcheck
# (PSR: close resources; propagate errors). Typed depth beyond portable rg.
# Usage: bash scripts/go-golangci-gate.sh [root]
# Escape: GO_GOLANGCI_GATE_SKIP=1 for tiny modules that only use go-kit rg/fmt/vet.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${GO_GOLANGCI_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS go-golangci-gate (skipped via GO_GOLANGCI_GATE_SKIP=1)"
  exit 0
fi

CFG=""
for candidate in .golangci.yml .golangci.yaml golangci.yml; do
  if [[ -f "$candidate" ]]; then CFG="$candidate"; break; fi
done

if [[ -z "$CFG" ]]; then
  echo "FAIL: no .golangci.yml (copy go-kit/templates/golangci/golangci.yml; PSR close/errors depth)"
  exit 1
fi

fail=0
has() {
  local key="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -q "^[[:space:]]*-[[:space:]]*$key[[:space:]]*$|^[[:space:]]*-[[:space:]]*$key[[:space:]]*#" "$CFG" \
      || rg -q "enable:.*\b$key\b" "$CFG"
  else
    grep -Eq "^[[:space:]]*-[[:space:]]*$key([[:space:]]|#|$)" "$CFG"
  fi
}

if ! has bodyclose; then
  echo "FAIL: $CFG missing bodyclose (PSR: close HTTP response bodies)"
  fail=1
fi
if ! has errcheck; then
  echo "FAIL: $CFG missing errcheck (PSR: propagate errors; do not ignore returns)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS go-golangci-gate ($ROOT/$CFG)"
