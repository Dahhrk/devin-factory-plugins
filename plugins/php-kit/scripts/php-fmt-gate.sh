#!/usr/bin/env bash
# Tier 0.5a: Pint / php-cs-fixer wiring as agreed formatter (PSR PHP).
# Live pint/php-cs-fixer --dry-run when tool exists unless PHP_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/php-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . \( -name '*.php' -o -name '*.phtml' \) -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/tmp/*' -not -path '*/node_modules/*' -not -path '*/test/*' -not -path '*/tests/*' -not -path '*/Tests/*' -not -path '*/storage/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no PHP sources under $ROOT"
  exit 1
fi

has_cfg=0
# Pint / php-cs-fixer config files
for f in pint.json .php-cs-fixer.php .php-cs-fixer.dist.php .php_cs .php-cs-fixer.cache; do
  [[ -f $f ]] && has_cfg=1
done
# composer require laravel/pint or friendsofphp/php-cs-fixer
if [[ -f composer.json ]]; then
  if rg -qi '"laravel/pint"|"friendsofphp/php-cs-fixer"|"php-cs-fixer"' composer.json 2>/dev/null; then has_cfg=1; fi
fi
# CI pint / php-cs-fixer
if [[ -d .github/workflows ]]; then
  if rg -qi 'pint|php-cs-fixer|php_cs_fixer' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi

if [[ "${PHP_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS php-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no Pint/php-cs-fixer wiring (copy php-kit/templates/pint.json; or unset PHP_FMT_CONFIG_ONLY)"
  exit 1
fi

run_fmt() {
  if [[ -x vendor/bin/pint ]]; then
    vendor/bin/pint --test 2>/dev/null
    return $?
  fi
  if command -v pint >/dev/null 2>&1; then
    pint --test 2>/dev/null
    return $?
  fi
  if [[ -x vendor/bin/php-cs-fixer ]]; then
    vendor/bin/php-cs-fixer fix --dry-run --diff 2>/dev/null
    return $?
  fi
  if command -v php-cs-fixer >/dev/null 2>&1; then
    php-cs-fixer fix --dry-run --diff 2>/dev/null
    return $?
  fi
  return 127
}

if run_fmt; then
  echo "PASS php-fmt-gate ($ROOT, live formatter, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS php-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install pint or php-cs-fixer for live)"
    exit 0
  fi
  echo "FAIL: pint/php-cs-fixer not on PATH and no pint.json / .php-cs-fixer.php / composer / CI wiring (PSR: Pint or php-cs-fixer)"
  exit 1
fi

# live failure may be host noise; fall through to config if present
if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS php-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: formatter would rewrite or flag sources (PSR: Pint / php-cs-fixer)"
exit 1
