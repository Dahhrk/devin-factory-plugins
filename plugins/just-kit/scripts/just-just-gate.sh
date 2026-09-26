#!/usr/bin/env bash
# Tier 1: require just / justfile toolchain wiring (PSR Just language-farm).
# Live `just --version` when resolvable unless JUST_JUST_CONFIG_ONLY=1.
# Portable bar: justfile / *.just / CI just.
# Escape: JUST_JUST_GATE_SKIP=1.
# Usage: bash scripts/just-just-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${JUST_JUST_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS just-just-gate (skipped via JUST_JUST_GATE_SKIP=1)"
  exit 0
fi

mapfile -t just_files < <(find . \( \
  -name 'justfile' -o -name 'Justfile' -o -name '.justfile' \
  -o -name '*.just' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' \
  2>/dev/null | sort || true)
if [[ ${#just_files[@]} -eq 0 ]]; then
  echo "FAIL: no justfile / *.just under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real Just anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)(?:^[a-zA-Z_][a-zA-Z0-9_-]*\s*:|^\[(?:script|group|no-cd|private|confirm|linux|macos|windows|unix|openbsd|freebsd)\b|^\s*import\??\s+\S|^\s*mod\??\s+\S|^set\s+\S|^\s*[a-zA-Z_][a-zA-Z0-9_]*\s*:?=)'

if rg -qP --glob 'justfile' --glob 'Justfile' --glob '.justfile' \
  --glob '*.just' \
  --glob '!**/.git/**' --glob '!**/vendor/**' \
  "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="just-instructions"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])just(\s|$|[^\w])|just\s+--|JUSTFLAGS' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: Just instructions, or CI that names just.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no just wiring (justfile instructions / CI; PSR: Just toolchain)"
  exit 1
fi

if [[ "${JUST_JUST_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS just-just-gate ($ROOT, config-only, ${#just_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v just >/dev/null 2>&1; then
  set +e
  just --version >/tmp/just-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/just-gate-ver.$$.out"
    echo "PASS just-just-gate ($ROOT, live just, ${#just_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/just-gate-ver.$$.out"
fi

echo "PASS just-just-gate ($ROOT, config-only fallback, ${#just_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
