#!/usr/bin/env bash
# Tier 1: require phpstan or psalm wiring (PSR PHP language-farm).
# Does not run the analyzer (host-dependent); proves phpstan/psalm config or
# composer require. Escape: PHP_STAN_GATE_SKIP=1.
# Usage: bash scripts/php-stan-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${PHP_STAN_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS php-stan-gate (skipped via PHP_STAN_GATE_SKIP=1)"
  exit 0
fi

found=0

# Config files
for f in phpstan.neon phpstan.neon.dist phpstan.dist.neon phpstan.src.neon.dist psalm.xml psalm.xml.dist; do
  if [[ -f "$f" ]]; then found=1; fi
done

# composer require
if [[ -f composer.json ]] && rg -qi '"phpstan/phpstan"|"larastan/larastan"|"phpstan/phpstan-strict-rules"|"vimeo/psalm"|"psalm/plugin-phpunit"' composer.json 2>/dev/null; then
  found=1
fi

# Nested configs (monorepo)
if [[ "$found" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name 'phpstan.neon' -o -name 'phpstan.neon.dist' -o -name 'phpstan.dist.neon' -o -name 'phpstan.src.neon.dist' -o -name 'psalm.xml' -o -name 'psalm.xml.dist' \) \
      -not -path '*/vendor/*' -not -path '*/.git/*' 2>/dev/null \
      | head -1 | rg -q .; then
    found=1
  fi
fi

# CI mentions
if [[ "$found" -eq 0 ]] && [[ -d .github/workflows ]]; then
  if rg -qi 'phpstan|psalm|larastan' .github/workflows 2>/dev/null; then
    found=1
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no phpstan/psalm wiring (phpstan.neon* / psalm.xml* or composer require; PSR language-farm requires static analysis)"
  exit 1
fi
echo "PASS php-stan-gate ($ROOT)"
