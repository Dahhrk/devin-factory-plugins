#!/usr/bin/env bash
# Tier 1: require lintr lint wiring (PSR R language-farm).
# Live lintr::lint_dir when Rscript + lintr exist unless R_LINTR_CONFIG_ONLY=1.
# Portable bar: .lintr / CI lintr::lint|lint_dir|lint_package.
# Config text must keep T_and_F_symbol_linter and undesirable_function_linter
# enabled (not assigned NULL / excluded).
# Escape: R_LINTR_GATE_SKIP=1.
# Usage: bash scripts/r-lintr-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${R_LINTR_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS r-lintr-gate (skipped via R_LINTR_GATE_SKIP=1)"
  exit 0
fi

mapfile -t r_files < <(find . \( -name '*.R' -o -name '*.r' -o -name '*.Rmd' -o -name '*.rmd' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/renv/*' -not -path '*/packrat/*' \
  2>/dev/null | sort || true)
if [[ ${#r_files[@]} -eq 0 ]]; then
  echo "FAIL: no R sources under $ROOT"
  exit 1
fi

CFG=""
CFG_TEXT=""
for candidate in .lintr .lintr.R lintr.linter_file; do
  if [[ -f "$candidate" ]]; then
    CFG="$candidate"
    CFG_TEXT="$(cat "$candidate")"
    break
  fi
done

has_file_cfg=0
[[ -n "$CFG" ]] && has_file_cfg=1

if [[ "$has_file_cfg" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name '.lintr' -o -name '.lintr.R' \) -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested" ]]; then
    has_file_cfg=1
    CFG="$nested"
    CFG_TEXT="$(cat "$nested")"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi 'lintr::(lint|lint_dir|lint_package)|lintr[[:space:]]' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no lintr wiring (.lintr / CI lintr::lint|lint_dir|lint_package; PSR: lintr lint)"
  exit 1
fi

# Require PSR linter encode when a product .lintr is present.
require_linter_enabled() {
  local name="$1"
  local flat
  flat="$(echo "$CFG_TEXT" | tr '\n' ' ')"
  # Fail if explicitly nulled: name = NULL or name=NULL
  if echo "$flat" | rg -qi "${name}[[:space:]]*=[[:space:]]*NULL"; then
    echo "FAIL: $CFG sets ${name} = NULL (PSR: keep ${name} enabled)"
    return 1
  fi
  # Product bar: require the linter name present in config text.
  if ! echo "$CFG_TEXT" | rg -q "${name}"; then
    echo "FAIL: $CFG missing ${name} encode (PSR: lintr ${name} bar)"
    return 1
  fi
  return 0
}

if [[ -n "$CFG_TEXT" ]]; then
  fail_rules=0
  require_linter_enabled "T_and_F_symbol_linter" || fail_rules=1
  require_linter_enabled "undesirable_function_linter" || fail_rules=1
  if [[ "$fail_rules" -ne 0 ]]; then
    exit 1
  fi
fi

if [[ "${R_LINTR_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS r-lintr-gate ($ROOT, config-only, ${#r_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v Rscript >/dev/null 2>&1; then
  set +e
  Rscript -e '
    if (!requireNamespace("lintr", quietly = TRUE)) quit(status = 127)
    cfg <- if (file.exists(".lintr")) ".lintr" else NULL
    path <- if (dir.exists("R")) "R" else "."
    lints <- lintr::lint_dir(path)
    if (length(lints) > 0) { print(lints); quit(status = 1) }
    quit(status = 0)
  ' >/tmp/lintr-gate-lint.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/lintr-gate-lint.$$.out"
    echo "PASS r-lintr-gate ($ROOT, live lintr::lint_dir, ${#r_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/lintr-gate-lint.$$.out"
fi

echo "PASS r-lintr-gate ($ROOT, config-only fallback, ${#r_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
