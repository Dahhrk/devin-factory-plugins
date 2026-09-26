#!/usr/bin/env bash
# Tier 0.5a: clang-format clean (PSR C / language-farm: clang-format).
# Live `clang-format --dry-run -Werror` when clang-format exists.
# Otherwise require .clang-format (config presence). Force config-only:
# C_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/c-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . \( -name '*.c' -o -name '*.h' \) -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/cmake-build*/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no .c/.h files under $ROOT"
  exit 1
fi

has_cfg=0
[[ -f .clang-format ]] && has_cfg=1
[[ -f clang-format ]] && has_cfg=1

if [[ "${C_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS c-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no .clang-format (copy c-kit/templates/clang-format; or unset C_FMT_CONFIG_ONLY)"
  exit 1
fi

if command -v clang-format >/dev/null 2>&1; then
  # Prefer --dry-run -Werror (clang-format >= 10); fall back to --output-replacements-xml.
  if clang-format --help 2>&1 | rg -q 'dry-run|Werror' 2>/dev/null; then
    clang-format --dry-run -Werror "${files[@]}"
  else
    # Older clang-format: non-empty replacements => fail
    xml=$(clang-format -output-replacements-xml "${files[@]}" 2>/dev/null || true)
    if echo "$xml" | rg -q '<replacement '; then
      echo "FAIL: clang-format would rewrite sources (PSR: clang-format)"
      exit 1
    fi
  fi
  echo "PASS c-fmt-gate ($ROOT, live clang-format, ${#files[@]} files)"
  exit 0
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS c-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install clang-format for live)"
  exit 0
fi

echo "FAIL: clang-format not on PATH and no .clang-format (PSR: clang-format)"
exit 1
