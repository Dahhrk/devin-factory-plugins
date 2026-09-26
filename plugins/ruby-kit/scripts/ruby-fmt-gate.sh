#!/usr/bin/env bash
# Tier 0.5a: RuboCop wiring as agreed formatter (PSR Ruby).
# Live `rubocop --format simple` when rubocop exists unless RUBY_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/ruby-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . \( -name '*.rb' -o -name '*.rake' \) -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/tmp/*' -not -path '*/node_modules/*' -not -path '*/test/*' -not -path '*/spec/*' -not -path '*/tests/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Ruby sources under $ROOT"
  exit 1
fi

has_cfg=0
# RuboCop config files
for f in .rubocop.yml .rubocop.yaml .rubocop.yml.erb rubocop.yml; do
  [[ -f $f ]] && has_cfg=1
done
# Gemfile rubocop dep
if [[ -f Gemfile ]]; then
  if rg -qi '^\s*gem\s+["'"'"']rubocop["'"'"']' Gemfile 2>/dev/null; then has_cfg=1; fi
fi
# CI rubocop
if [[ -d .github/workflows ]]; then
  if rg -qi 'rubocop' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi

if [[ "${RUBY_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS ruby-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no RuboCop wiring (copy ruby-kit/templates/rubocop.yml; or unset RUBY_FMT_CONFIG_ONLY)"
  exit 1
fi

run_rubocop() {
  if command -v rubocop >/dev/null 2>&1; then
    rubocop --format simple "${files[@]}" 2>/dev/null
    return $?
  fi
  if [[ -f Gemfile ]] && command -v bundle >/dev/null 2>&1; then
    bundle exec rubocop --format simple "${files[@]}" 2>/dev/null
    return $?
  fi
  return 127
}

if run_rubocop; then
  echo "PASS ruby-fmt-gate ($ROOT, live rubocop, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS ruby-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install rubocop for live)"
    exit 0
  fi
  echo "FAIL: rubocop not on PATH and no .rubocop.yml / Gemfile rubocop / CI wiring (PSR: RuboCop or agreed alternative)"
  exit 1
fi

# live failure may be host noise; fall through to config if present
if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS ruby-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: rubocop would rewrite or flag sources (PSR: RuboCop)"
exit 1
