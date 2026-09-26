#!/usr/bin/env bash
# Tier 1: require mako toolchain wiring (PSR Mako language-farm).
# Live import when resolvable unless MAKO_MAKO_CONFIG_ONLY=1.
# Portable bar: from mako / import mako / requirements|pyproject mako / CI.
# Escape: MAKO_MAKO_GATE_SKIP=1.
# Usage: bash scripts/mako-mako-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${MAKO_MAKO_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS mako-mako-gate (skipped via MAKO_MAKO_GATE_SKIP=1)"
  exit 0
fi

mapfile -t mako_files < <(find . \( \
  -name '*.mako' -o -name '*.Mako' -o -name '*.html' -o -name '*.HTML' \
  -o -name '*.py' -o -name '*.pyi' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' \
  2>/dev/null | sort || true)
if [[ ${#mako_files[@]} -eq 0 ]]; then
  echo "FAIL: no Mako / Python sources under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real mako import / dependency key (not bare substring in a comment-only name).
IMPORT_PAT='(?m)^(?:from\s+mako(?:\.|\s)|import\s+mako(?:\.|\s|,|$))'
DEP_PAT='(?i)(^|[^\w-])mako([^\w-]|$)|["'\'']mako["'\'']\s*[>=<]|^\s*mako\s*(==|>=|~=|!=|<=|<|>)'

if rg -qP --glob '*.py' --glob '*.pyi' --glob '!**/.git/**' --glob '!**/vendor/**' --glob '!**/.venv/**' "$IMPORT_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="mako-import"
fi

if [[ "$has_file_cfg" -eq 0 ]]; then
  for candidate in requirements.txt requirements-dev.txt pyproject.toml setup.cfg setup.py Pipfile; do
    if [[ -f "$candidate" ]] && rg -qP "$DEP_PAT" "$candidate" 2>/dev/null; then
      has_file_cfg=1
      CFG="$candidate"
      break
    fi
  done
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])mako([^\w-]|$)|mako-lint|TemplateLookup' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: mako import/dep, or CI that names mako.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no mako wiring (from/import mako / requirements|pyproject / CI; PSR: Mako toolchain)"
  exit 1
fi

if [[ "${MAKO_MAKO_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS mako-mako-gate ($ROOT, config-only, ${#mako_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v python3 >/dev/null 2>&1; then
  set +e
  python3 -c "import mako" >/tmp/mako-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/mako-gate-ver.$$.out"
    echo "PASS mako-mako-gate ($ROOT, live mako, ${#mako_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/mako-gate-ver.$$.out"
fi

echo "PASS mako-mako-gate ($ROOT, config-only fallback, ${#mako_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
