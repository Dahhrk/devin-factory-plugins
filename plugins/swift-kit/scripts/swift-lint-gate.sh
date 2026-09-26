#!/usr/bin/env bash
# Tier 1: require SwiftLint wiring (PSR Swift language-farm).
# Does not run the analyzer (host-dependent); proves .swiftlint.yml or CI.
# Escape: SWIFT_LINT_GATE_SKIP=1.
# Usage: bash scripts/swift-lint-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${SWIFT_LINT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS swift-lint-gate (skipped via SWIFT_LINT_GATE_SKIP=1)"
  exit 0
fi

found=0

# Config files
for f in .swiftlint.yml .swiftlint.yaml .swiftlint.yml.example; do
  if [[ -f "$f" ]]; then found=1; fi
done

# Nested configs (monorepo / packages)
if [[ "$found" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name '.swiftlint.yml' -o -name '.swiftlint.yaml' \) \
      -not -path '*/.git/*' -not -path '*/.build/*' 2>/dev/null \
      | head -1 | rg -q .; then
    found=1
  fi
fi

# Mintfile / Package plugin / scripts
if [[ "$found" -eq 0 ]]; then
  if [[ -f Mintfile ]] && rg -qi 'SwiftLint|swiftlint' Mintfile 2>/dev/null; then found=1; fi
  if [[ -f Package.swift ]] && rg -qi 'SwiftLint|swiftlint' Package.swift 2>/dev/null; then found=1; fi
fi

# CI mentions
if [[ "$found" -eq 0 ]] && [[ -d .github/workflows ]]; then
  if rg -qi 'swiftlint|SwiftLint' .github/workflows 2>/dev/null; then
    found=1
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no SwiftLint wiring (.swiftlint.yml / .swiftlint.yaml or CI / Mintfile / Package; PSR language-farm requires SwiftLint)"
  exit 1
fi
echo "PASS swift-lint-gate ($ROOT)"
