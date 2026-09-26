#!/usr/bin/env bash
# Tier 1: clang-format clean (PSR ObjC / language-farm: clang-format).
# Live `clang-format --dry-run -Werror` when clang-format exists.
# Otherwise require .clang-format (config presence). Force config-only:
# OBJC_FMT_CONFIG_ONLY=1.
# Escape: OBJC_FMT_GATE_SKIP=1.
# Usage: bash scripts/objc-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${OBJC_FMT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS objc-fmt-gate (skipped via OBJC_FMT_GATE_SKIP=1)"
  exit 0
fi

mapfile -t files < <(find . \( -name '*.m' -o -name '*.h' -o -name '*.mm' -o -name '*.M' \) \
  -not -path '*/.git/*' -not -path '*/Pods/*' -not -path '*/Carthage/*' \
  -not -path '*/DerivedData/*' -not -path '*/build/*' -not -path '*/Build/*' \
  -not -path '*/testdata/*' -not -path '*/Examples/*' -not -path '*/examples/*' \
  -not -path '*/Tests/*' -not -path '*/tests/*' \
  2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Objective-C sources under $ROOT"
  exit 1
fi

has_cfg=0
[[ -f .clang-format ]] && has_cfg=1
[[ -f clang-format ]] && has_cfg=1
if [[ "$has_cfg" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name '.clang-format' -o -name 'clang-format' \) \
      -not -path '*/.git/*' -not -path '*/Pods/*' 2>/dev/null \
      | head -1 | rg -q .; then
    has_cfg=1
  fi
fi
if [[ -d .github/workflows ]]; then
  if rg -qi 'clang-format' .github/workflows 2>/dev/null; then
    has_cfg=1
  fi
fi

if [[ "${OBJC_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS objc-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no .clang-format / CI clang-format wiring (copy objc-kit/templates/.clang-format; or unset OBJC_FMT_CONFIG_ONLY)"
  exit 1
fi

if command -v clang-format >/dev/null 2>&1; then
  if clang-format --help 2>&1 | rg -q 'dry-run|Werror' 2>/dev/null; then
    clang-format --dry-run -Werror "${files[@]}"
  else
    xml=$(clang-format -output-replacements-xml "${files[@]}" 2>/dev/null || true)
    if echo "$xml" | rg -q '<replacement '; then
      echo "FAIL: clang-format would rewrite sources (PSR: clang-format)"
      exit 1
    fi
  fi
  echo "PASS objc-fmt-gate ($ROOT, live clang-format, ${#files[@]} files)"
  exit 0
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS objc-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install clang-format for live)"
  exit 0
fi

echo "FAIL: clang-format not on PATH and no .clang-format / CI wiring (PSR: clang-format)"
exit 1
