#!/usr/bin/env bash
# Tier 1: require Lex/Yacc (Flex/Bison) toolchain wiring (PSR language-farm).
# Live `flex --version` / `bison --version` when resolvable unless
# LEXYACC_TOOL_CONFIG_ONLY=1.
# Portable bar: *.l *.y *.lex *.yacc *.ll *.yy / CI flex|bison|lex|yacc.
# Escape: LEXYACC_TOOL_GATE_SKIP=1.
# Usage: bash scripts/lexyacc-tool-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${LEXYACC_TOOL_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS lexyacc-tool-gate (skipped via LEXYACC_TOOL_GATE_SKIP=1)"
  exit 0
fi

mapfile -t ly_files < <(find . \( \
  -name '*.l' -o -name '*.y' -o -name '*.lex' -o -name '*.yacc' -o -name '*.ll' -o -name '*.yy' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' \
  2>/dev/null | sort || true)
if [[ ${#ly_files[@]} -eq 0 ]]; then
  echo "FAIL: no *.l / *.y / *.lex / *.yacc / *.ll / *.yy under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real Lex/Yacc anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)(?:^%%\s*$|^%\{|^%\}|^%option\b|^%token\b|^%left\b|^%right\b|^%nonassoc\b|^%type\b|^%start\b|^%union\b|^%define\b|^%code\b|^%top\b|^\s*yywrap\s*\(|^\s*yylex\s*\(|^\s*yyparse\s*\(|^%include\s+["'\'']?[^/"'\''\$])'

if rg -qP --glob '*.l' --glob '*.y' --glob '*.lex' --glob '*.yacc' --glob '*.ll' --glob '*.yy' \
  --glob '!**/.git/**' --glob '!**/vendor/**' \
  "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="lexyacc-instructions"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])(?:flex|bison|lex|yacc)(\s|$|[^\w-])|flex\s+-o|bison\s+-d|\.l\b|\.y\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no lexyacc wiring (*.l/*.y instructions / CI; PSR: Lex/Yacc toolchain)"
  exit 1
fi

if [[ "${LEXYACC_TOOL_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS lexyacc-tool-gate ($ROOT, config-only, ${#ly_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v flex >/dev/null 2>&1; then
  set +e
  flex --version >/tmp/lexyacc-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/lexyacc-gate-ver.$$.out"
    echo "PASS lexyacc-tool-gate ($ROOT, live flex, ${#ly_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/lexyacc-gate-ver.$$.out"
fi
if command -v bison >/dev/null 2>&1; then
  set +e
  bison --version >/tmp/lexyacc-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/lexyacc-gate-ver.$$.out"
    echo "PASS lexyacc-tool-gate ($ROOT, live bison, ${#ly_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/lexyacc-gate-ver.$$.out"
fi

echo "PASS lexyacc-tool-gate ($ROOT, config-only fallback, ${#ly_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
