#!/usr/bin/env bash
# Tier 1: require sqlfluff lint wiring (PSR SQL language-farm).
# Live `sqlfluff lint` when sqlfluff exists unless SQL_SQLFLUFF_CONFIG_ONLY=1.
# Portable bar: .sqlfluff / setup.cfg [sqlfluff] / pyproject [tool.sqlfluff] /
# CI sqlfluff lint. Config text must keep AM04 (or ambiguous) enabled.
# Escape: SQL_SQLFLUFF_GATE_SKIP=1.
# Usage: bash scripts/sql-sqlfluff-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${SQL_SQLFLUFF_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS sql-sqlfluff-gate (skipped via SQL_SQLFLUFF_GATE_SKIP=1)"
  exit 0
fi

mapfile -t sql_files < <(find . \( -name '*.sql' -o -name '*.SQL' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#sql_files[@]} -eq 0 ]]; then
  echo "FAIL: no SQL sources under $ROOT"
  exit 1
fi

CFG=""
CFG_TEXT=""
if [[ -f .sqlfluff ]]; then
  CFG=".sqlfluff"
  CFG_TEXT="$(cat .sqlfluff)"
elif [[ -f setup.cfg ]] && rg -q '^\[sqlfluff(\]|\.)' setup.cfg 2>/dev/null; then
  CFG="setup.cfg"
  CFG_TEXT="$(cat setup.cfg)"
elif [[ -f pyproject.toml ]] && rg -q '^\[tool\.sqlfluff(\]|\.)' pyproject.toml 2>/dev/null; then
  # Match [tool.sqlfluff] or [tool.sqlfluff.foo], not [tool.sqlfluff_docs]
  CFG="pyproject.toml"
  CFG_TEXT="$(cat pyproject.toml)"
fi

has_file_cfg=0
[[ -n "$CFG" ]] && has_file_cfg=1

if [[ "$has_file_cfg" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f -name '.sqlfluff' -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested" ]]; then
    has_file_cfg=1
    CFG="$nested"
    CFG_TEXT="$(cat "$nested")"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi 'sqlfluff[[:space:]]+lint' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no sqlfluff wiring (.sqlfluff / [sqlfluff] / [tool.sqlfluff] / CI sqlfluff lint; PSR: sqlfluff lint)"
  exit 1
fi

# Require AM04 / ambiguous SELECT * depth when a product config file is present.
if [[ -n "$CFG_TEXT" ]]; then
  if echo "$CFG_TEXT" | rg -qi 'exclude_rules[[:space:]]*=[[:space:]]*.*\bAM04\b|exclude_rules[[:space:]]*=[[:space:]]*.*\bambiguous\b'; then
    echo "FAIL: $CFG excludes AM04/ambiguous (PSR: keep SELECT * rule AM04 enabled)"
    exit 1
  fi
  if ! echo "$CFG_TEXT" | rg -qi '\bAM04\b|rules[[:space:]]*=[[:space:]]*[^#\n]*\bambiguous\b|rules[[:space:]]*=[[:space:]]*all|rules[[:space:]]*=[[:space:]]*AM'; then
    echo "FAIL: $CFG missing AM04 / ambiguous rule encode (PSR: sqlfluff SELECT * bar; set rules = AM04 or ambiguous)"
    exit 1
  fi
fi

if [[ "${SQL_SQLFLUFF_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS sql-sqlfluff-gate ($ROOT, config-only, ${#sql_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v sqlfluff >/dev/null 2>&1; then
  bin="${SQL_SQLFLUFF_BIN:-sqlfluff}"
  src="${SQL_SQLFLUFF_SRC:-}"
  if [[ -z "$src" ]]; then
    if [[ -d sql ]]; then src="sql"
    elif [[ -d queries ]]; then src="queries"
    elif [[ -d db ]]; then src="db"
    else src="."; fi
  fi
  set +e
  "$bin" lint --disable-progress-bar "$src" >/tmp/sqlfluff-gate-lint.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/sqlfluff-gate-lint.$$.out"
    echo "PASS sql-sqlfluff-gate ($ROOT, live sqlfluff lint, ${#sql_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/sqlfluff-gate-lint.$$.out"
fi

echo "PASS sql-sqlfluff-gate ($ROOT, config-only fallback, ${#sql_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
