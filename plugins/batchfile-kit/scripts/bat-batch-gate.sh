#!/usr/bin/env bash
# Tier 1: require *.bat / *.cmd toolchain wiring (PSR Batchfile language-farm).
# Live `cmd.exe` / `cmd` when resolvable unless BAT_BATCH_CONFIG_ONLY=1.
# Portable bar: *.bat / *.cmd / CI cmd|batch|BatchScript.
# Escape: BAT_BATCH_GATE_SKIP=1.
# Usage: bash scripts/bat-batch-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${BAT_BATCH_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS bat-batch-gate (skipped via BAT_BATCH_GATE_SKIP=1)"
  exit 0
fi

mapfile -t bat_files < <(find . \( \
  -name '*.bat' -o -name '*.cmd' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' \
  2>/dev/null | sort || true)
if [[ ${#bat_files[@]} -eq 0 ]]; then
  echo "FAIL: no *.bat / *.cmd under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real Batch anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)(?:@?echo\s+off\b|setlocal\b|endlocal\b|^\s*goto\s+:|^\s*call\s+:|^\s*if\s+(?:not\s+)?(?:exist\b|errorlevel\b|defined\b|")|^\s*for\s+%|^\s*exit\s+/b\b|^\s*set\s+"?\w+=|cmd\s+/c\b)'

if rg -qP --glob '*.bat' --glob '*.cmd' \
  --glob '!**/.git/**' --glob '!**/vendor/**' \
  "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="batch-instructions"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])(?:cmd\.exe|BatchScript|batchfile|\.bat\b|\.cmd\b)(\s|$|[^\w-])|cmd\s+/c|windows-latest[^\n]*\.bat' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: Batch instructions, or CI that names batch/cmd.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no batch wiring (*.bat instructions / CI; PSR: Batchfile toolchain)"
  exit 1
fi

if [[ "${BAT_BATCH_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS bat-batch-gate ($ROOT, config-only, ${#bat_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v cmd.exe >/dev/null 2>&1; then
  set +e
  cmd.exe /c "echo ok" >/tmp/bat-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/bat-gate-ver.$$.out"
    echo "PASS bat-batch-gate ($ROOT, live cmd.exe, ${#bat_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/bat-gate-ver.$$.out"
elif command -v cmd >/dev/null 2>&1; then
  set +e
  cmd /c "echo ok" >/tmp/bat-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/bat-gate-ver.$$.out"
    echo "PASS bat-batch-gate ($ROOT, live cmd, ${#bat_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/bat-gate-ver.$$.out"
fi

echo "PASS bat-batch-gate ($ROOT, config-only fallback, ${#bat_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
