#!/usr/bin/env bash
# Tier 1: require rubocop-performance plugin wiring (PSR Ruby language-farm).
# Does not run RuboCop (host-dependent); proves rubocop-performance is required
# in .rubocop.yml plugins or Gemfile. Escape: RUBY_RUBOCOP_PERF_GATE_SKIP=1.
# Usage: bash scripts/ruby-rubocop-performance-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${RUBY_RUBOCOP_PERF_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS ruby-rubocop-performance-gate (skipped via RUBY_RUBOCOP_PERF_GATE_SKIP=1)"
  exit 0
fi

found=0

# .rubocop.yml plugins: - rubocop-performance  OR require: rubocop-performance
for f in .rubocop.yml .rubocop.yaml rubocop.yml; do
  if [[ -f "$f" ]] && rg -qi 'rubocop-performance|rubocop/performance' "$f" 2>/dev/null; then
    found=1
  fi
done

# Gemfile gem "rubocop-performance"
if [[ -f Gemfile ]] && rg -qi '^\s*gem\s+["'"'"']rubocop-performance["'"'"']' Gemfile 2>/dev/null; then
  found=1
fi

# Nested configs (monorepo)
if [[ "$found" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name '.rubocop.yml' -o -name '.rubocop.yaml' \) \
      -not -path '*/vendor/*' -not -path '*/.git/*' 2>/dev/null \
      | while read -r f; do rg -qi 'rubocop-performance|rubocop/performance' "$f" && echo hit; done \
      | rg -q hit; then
    found=1
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no rubocop-performance wiring (.rubocop.yml plugins or Gemfile gem; PSR language-farm requires rubocop-performance)"
  exit 1
fi
echo "PASS ruby-rubocop-performance-gate ($ROOT)"
