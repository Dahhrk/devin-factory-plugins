#!/usr/bin/env bash
# Tier 1: require make / Makefile toolchain wiring (PSR Makefile language-farm).
# Live `make --version` when resolvable unless MAKEFILE_MAKE_CONFIG_ONLY=1.
# Portable bar: Makefile / *.mk / CI make.
# Escape: MAKEFILE_MAKE_GATE_SKIP=1.
# Usage: bash scripts/makefile-make-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${MAKEFILE_MAKE_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS makefile-make-gate (skipped via MAKEFILE_MAKE_GATE_SKIP=1)"
  exit 0
fi

mapfile -t mk_files < <(find . \( \
  -name 'Makefile' -o -name 'makefile' -o -name 'GNUmakefile' \
  -o -name '*.mk' -o -name '*.make' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' \
  2>/dev/null | sort || true)
if [[ ${#mk_files[@]} -eq 0 ]]; then
  echo "FAIL: no Makefile / *.mk under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real Make anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)(?:^\.PHONY\b|^[a-zA-Z0-9_.%-]+\s*:|^[a-zA-Z_][a-zA-Z0-9_]*\s*[?:]?=|^\s*-?include\s+\S)'

if rg -qP --glob 'Makefile' --glob 'makefile' --glob 'GNUmakefile' \
  --glob '*.mk' --glob '*.make' \
  --glob '!**/.git/**' --glob '!**/vendor/**' \
  "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="make-instructions"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])make(\s|$|[^\w])|make\s+-C|MAKEFLAGS|GNU Make' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: Make instructions, or CI that names make.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no make wiring (Makefile instructions / CI; PSR: Make toolchain)"
  exit 1
fi

if [[ "${MAKEFILE_MAKE_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS makefile-make-gate ($ROOT, config-only, ${#mk_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v make >/dev/null 2>&1; then
  set +e
  make --version >/tmp/makefile-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/makefile-gate-ver.$$.out"
    echo "PASS makefile-make-gate ($ROOT, live make, ${#mk_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/makefile-gate-ver.$$.out"
fi

echo "PASS makefile-make-gate ($ROOT, config-only fallback, ${#mk_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
