#!/usr/bin/env bash
# Tier 1: require GnuCOBOL cobc build wiring (PSR COBOL language-farm).
# Portable bar: Makefile / CMake / meson / CI mentioning cobc.
# Escape: COBOL_COBC_GATE_SKIP=1.
# Usage: bash scripts/cobol-cobc-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${COBOL_COBC_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS cobol-cobc-gate (skipped via COBOL_COBC_GATE_SKIP=1)"
  exit 0
fi

mapfile -t cob_files < <(find . \( \
  -name '*.cob' -o -name '*.cbl' -o -name '*.COB' -o -name '*.CBL' \
  -o -name '*.cpy' -o -name '*.CPY' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/testdata/*' -not -path '*/tests/*' -not -path '*/Tests/*' \
  2>/dev/null | sort || true)
if [[ ${#cob_files[@]} -eq 0 ]]; then
  echo "FAIL: no COBOL sources under $ROOT"
  exit 1
fi

has_wiring=0
CFG=""

for mf in Makefile makefile GNUmakefile; do
  if [[ -f "$mf" ]] && rg -qi '\bcobc\b' "$mf" 2>/dev/null; then
    has_wiring=1
    CFG="$mf"
    break
  fi
done

if [[ "$has_wiring" -eq 0 && -f CMakeLists.txt ]]; then
  if rg -qi '\bcobc\b|gnu[[:space:]]*cobol|GnuCOBOL' CMakeLists.txt 2>/dev/null; then
    has_wiring=1
    CFG="CMakeLists.txt"
  fi
fi

if [[ "$has_wiring" -eq 0 && -f meson.build ]]; then
  if rg -qi '\bcobc\b|gnucobol' meson.build 2>/dev/null; then
    has_wiring=1
    CFG="meson.build"
  fi
fi

if [[ "$has_wiring" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name 'Makefile' -o -name 'makefile' -o -name 'CMakeLists.txt' -o -name 'meson.build' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -20 || true)"
  for f in $nested; do
    if rg -qi '\bcobc\b|GnuCOBOL|gnu[[:space:]]*cobol' "$f" 2>/dev/null; then
      has_wiring=1
      CFG="$f"
      break
    fi
  done
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi '\bcobc\b|gnucobol|gnu[[:space:]]*cobol' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no cobc wiring (Makefile/CMake/meson/CI mentioning cobc; PSR: GnuCOBOL cobc toolchain)"
  exit 1
fi

if [[ "${COBOL_COBC_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS cobol-cobc-gate ($ROOT, config-only, ${#cob_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v cobc >/dev/null 2>&1; then
  live_rc=0
fi

echo "PASS cobol-cobc-gate ($ROOT, config-only fallback, ${#cob_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
