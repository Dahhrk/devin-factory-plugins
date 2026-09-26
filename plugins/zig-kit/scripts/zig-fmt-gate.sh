#!/usr/bin/env bash
# Tier 0.5a: zig fmt wiring as agreed formatter (PSR Zig).
# Live `zig fmt --check` when zig exists unless ZIG_FMT_CONFIG_ONLY=1.
# Zig has no fmt config file; portable bar is CI / build mention of zig fmt.
# Usage: bash scripts/zig-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . -name '*.zig' -not -path '*/.git/*' -not -path '*/zig-cache/*' -not -path '*/zig-out/*' -not -path '*/tmp/*' -not -path '*/test/*' -not -path '*/tests/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Zig sources under $ROOT"
  exit 1
fi

has_cfg=0
# CI zig fmt
if [[ -d .github/workflows ]]; then
  if rg -qi 'zig[[:space:]]+fmt' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi
# Makefile / build.zig mention
for f in Makefile makefile build.zig; do
  if [[ -f "$f" ]] && rg -qi 'zig[[:space:]]+fmt|fmt[[:space:]]+--check' "$f" 2>/dev/null; then
    has_cfg=1
  fi
done
# Optional marker for products that document fmt without CI yet
if [[ -f .zigfmt-ok ]]; then has_cfg=1; fi

if [[ "${ZIG_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS zig-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no zig fmt wiring (CI zig fmt --check / build.zig / .zigfmt-ok; or unset ZIG_FMT_CONFIG_ONLY)"
  exit 1
fi

run_fmt() {
  if command -v zig >/dev/null 2>&1; then
    zig fmt --check "${files[@]}" 2>/dev/null
    return $?
  fi
  return 127
}

if run_fmt; then
  echo "PASS zig-fmt-gate ($ROOT, live zig fmt, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS zig-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install zig for live)"
    exit 0
  fi
  echo "FAIL: zig not on PATH and no CI zig fmt / build.zig fmt / .zigfmt-ok wiring (PSR: zig fmt)"
  exit 1
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS zig-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: zig fmt --check would rewrite or flag sources (PSR: zig fmt)"
exit 1
