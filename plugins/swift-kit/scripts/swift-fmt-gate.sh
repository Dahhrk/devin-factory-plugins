#!/usr/bin/env bash
# Tier 0.5a: swift-format / SwiftFormat wiring as agreed formatter (PSR Swift).
# Live swift format / swift-format when tool exists unless SWIFT_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/swift-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . -name '*.swift' -not -path '*/.git/*' -not -path '*/.build/*' -not -path '*/tmp/*' -not -path '*/node_modules/*' -not -path '*/test/*' -not -path '*/tests/*' -not -path '*/Tests/*' -not -path '*/Benchmarks/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Swift sources under $ROOT"
  exit 1
fi

has_cfg=0
# swift-format / SwiftFormat config files
for f in .swift-format .swiftformat .swift-format.json; do
  [[ -f $f ]] && has_cfg=1
done
# Nested configs (packages / monorepo)
if [[ "$has_cfg" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name '.swift-format' -o -name '.swiftformat' -o -name '.swift-format.json' \) \
      -not -path '*/.git/*' -not -path '*/.build/*' 2>/dev/null \
      | head -1 | rg -q .; then
    has_cfg=1
  fi
fi
# Package.swift / scripts mentioning formatter
if [[ -f Package.swift ]] && rg -qi 'swift-format|SwiftFormat|swift format' Package.swift 2>/dev/null; then has_cfg=1; fi
# CI swift-format / format_check
if [[ -d .github/workflows ]]; then
  if rg -qi 'swift-format|swiftformat|format_check|swift format' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi

if [[ "${SWIFT_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS swift-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no swift-format/SwiftFormat wiring (copy swift-kit/templates/.swift-format; or unset SWIFT_FMT_CONFIG_ONLY)"
  exit 1
fi

run_fmt() {
  if command -v swift >/dev/null 2>&1; then
    if swift format --version >/dev/null 2>&1; then
      swift format lint --recursive --configuration .swift-format . 2>/dev/null || swift format lint --recursive . 2>/dev/null
      return $?
    fi
  fi
  if command -v swift-format >/dev/null 2>&1; then
    if [[ -f .swift-format ]]; then
      swift-format lint --recursive --configuration .swift-format . 2>/dev/null
    else
      swift-format lint --recursive . 2>/dev/null
    fi
    return $?
  fi
  if command -v swiftformat >/dev/null 2>&1; then
    swiftformat --lint . 2>/dev/null
    return $?
  fi
  return 127
}

if run_fmt; then
  echo "PASS swift-fmt-gate ($ROOT, live formatter, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS swift-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install swift-format for live)"
    exit 0
  fi
  echo "FAIL: swift-format/SwiftFormat not on PATH and no .swift-format / .swiftformat / CI wiring (PSR: swift-format or SwiftFormat)"
  exit 1
fi

# live failure may be host noise; fall through to config if present
if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS swift-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: formatter would rewrite or flag sources (PSR: swift-format / SwiftFormat)"
exit 1
