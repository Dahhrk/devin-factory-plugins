#!/usr/bin/env bash
# Tier 1: require htmlhint lint wiring (PSR HTML language-farm).
# Live `htmlhint` when htmlhint exists unless HTML_HTMLHINT_CONFIG_ONLY=1.
# Portable bar: .htmlhintrc / .htmlhint.json / package.json "htmlhint" /
# CI htmlhint. Config text must keep alt-require, inline-script-disabled,
# and inline-style-disabled enabled (not false).
# Escape: HTML_HTMLHINT_GATE_SKIP=1.
# Usage: bash scripts/html-htmlhint-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${HTML_HTMLHINT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS html-htmlhint-gate (skipped via HTML_HTMLHINT_GATE_SKIP=1)"
  exit 0
fi

mapfile -t html_files < <(find . \( -name '*.html' -o -name '*.htm' -o -name '*.HTML' -o -name '*.HTM' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#html_files[@]} -eq 0 ]]; then
  echo "FAIL: no HTML sources under $ROOT"
  exit 1
fi

CFG=""
CFG_TEXT=""
if [[ -f .htmlhintrc ]]; then
  CFG=".htmlhintrc"
  CFG_TEXT="$(cat .htmlhintrc)"
elif [[ -f .htmlhint.json ]]; then
  CFG=".htmlhint.json"
  CFG_TEXT="$(cat .htmlhint.json)"
elif [[ -f htmlhint.json ]]; then
  CFG="htmlhint.json"
  CFG_TEXT="$(cat htmlhint.json)"
elif [[ -f package.json ]] && rg -q '"htmlhint"\s*:' package.json 2>/dev/null; then
  CFG="package.json"
  CFG_TEXT="$(cat package.json)"
fi

has_file_cfg=0
[[ -n "$CFG" ]] && has_file_cfg=1

if [[ "$has_file_cfg" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name '.htmlhintrc' -o -name '.htmlhint.json' \) -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested" ]]; then
    has_file_cfg=1
    CFG="$nested"
    CFG_TEXT="$(cat "$nested")"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi 'htmlhint' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no htmlhint wiring (.htmlhintrc / .htmlhint.json / package.json htmlhint / CI htmlhint; PSR: htmlhint lint)"
  exit 1
fi

# Require PSR rule encode when a product config file is present.
require_rule_true() {
  local rule="$1"
  # Fail if explicitly false
  if echo "$CFG_TEXT" | rg -qi "\"$rule\"[[:space:]]*:[[:space:]]*false"; then
    echo "FAIL: $CFG sets $rule=false (PSR: keep $rule enabled)"
    return 1
  fi
  # Require explicit true (or bare true in .htmlhintrc json)
  if ! echo "$CFG_TEXT" | rg -qi "\"$rule\"[[:space:]]*:[[:space:]]*true"; then
    echo "FAIL: $CFG missing $rule:true (PSR: htmlhint $rule bar)"
    return 1
  fi
  return 0
}

if [[ -n "$CFG_TEXT" ]]; then
  fail_rules=0
  require_rule_true "alt-require" || fail_rules=1
  require_rule_true "inline-script-disabled" || fail_rules=1
  require_rule_true "inline-style-disabled" || fail_rules=1
  if [[ "$fail_rules" -ne 0 ]]; then
    exit 1
  fi
fi

if [[ "${HTML_HTMLHINT_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS html-htmlhint-gate ($ROOT, config-only, ${#html_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v htmlhint >/dev/null 2>&1; then
  bin="${HTML_HTMLHINT_BIN:-htmlhint}"
  src="${HTML_HTMLHINT_SRC:-}"
  if [[ -z "$src" ]]; then
    if [[ -d public ]]; then src="public"
    elif [[ -d static ]]; then src="static"
    elif [[ -d templates ]]; then src="templates"
    else src="."; fi
  fi
  set +e
  "$bin" "$src" >/tmp/htmlhint-gate-lint.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/htmlhint-gate-lint.$$.out"
    echo "PASS html-htmlhint-gate ($ROOT, live htmlhint, ${#html_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/htmlhint-gate-lint.$$.out"
fi

echo "PASS html-htmlhint-gate ($ROOT, config-only fallback, ${#html_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
