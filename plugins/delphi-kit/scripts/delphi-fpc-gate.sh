#!/usr/bin/env bash
# Tier 1: require Free Pascal / Lazarus build wiring (PSR Delphi/Pascal language-farm).
# Portable bar: Makefile / CI / scripts mentioning fpc or lazbuild.
# Escape: DELPHI_FPC_GATE_SKIP=1.
# Usage: bash scripts/delphi-fpc-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${DELPHI_FPC_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS delphi-fpc-gate (skipped via DELPHI_FPC_GATE_SKIP=1)"
  exit 0
fi

mapfile -t pas_files < <(find . \( \
  -name '*.pas' -o -name '*.pp' -o -name '*.dpr' -o -name '*.lpr' \
  -o -name '*.PAS' -o -name '*.PP' -o -name '*.DPR' -o -name '*.LPR' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/testdata/*' -not -path '*/tests/*' -not -path '*/Tests/*' \
  2>/dev/null | sort || true)
if [[ ${#pas_files[@]} -eq 0 ]]; then
  echo "FAIL: no Delphi/Object Pascal sources under $ROOT"
  exit 1
fi

has_wiring=0
CFG=""

for mf in Makefile makefile GNUmakefile build-all.sh build.sh; do
  if [[ -f "$mf" ]] && rg -qi '\b(fpc|lazbuild)\b' "$mf" 2>/dev/null; then
    has_wiring=1
    CFG="$mf"
    break
  fi
done

if [[ "$has_wiring" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name 'Makefile' -o -name 'makefile' -o -name 'build-all.sh' -o -name 'build.sh' -o -name '*.yml' -o -name '*.yaml' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -40 || true)"
  for f in $nested; do
    if rg -qi '\b(fpc|lazbuild)\b' "$f" 2>/dev/null; then
      has_wiring=1
      CFG="$f"
      break
    fi
  done
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi '\b(fpc|lazbuild|freepascal|free[[:space:]]*pascal)\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no fpc/lazbuild wiring (Makefile/build script/CI mentioning fpc or lazbuild; PSR: Free Pascal / Lazarus toolchain)"
  exit 1
fi

if [[ "${DELPHI_FPC_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS delphi-fpc-gate ($ROOT, config-only, ${#pas_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v fpc >/dev/null 2>&1 || command -v lazbuild >/dev/null 2>&1; then
  live_rc=0
fi

echo "PASS delphi-fpc-gate ($ROOT, config-only fallback, ${#pas_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
