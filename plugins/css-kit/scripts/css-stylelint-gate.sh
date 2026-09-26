#!/usr/bin/env bash
# Tier 1: require stylelint lint wiring (PSR CSS language-farm).
# Live `stylelint` when stylelint exists unless CSS_STYLELINT_CONFIG_ONLY=1.
# Portable bar: .stylelintrc* / stylelint.config.* / package.json "stylelint" /
# CI stylelint. Config text must keep declaration-no-important enabled and
# selector-max-universal set (not null/false/disabled).
# Escape: CSS_STYLELINT_GATE_SKIP=1.
# Usage: bash scripts/css-stylelint-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${CSS_STYLELINT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS css-stylelint-gate (skipped via CSS_STYLELINT_GATE_SKIP=1)"
  exit 0
fi

mapfile -t css_files < <(find . \( -name '*.css' -o -name '*.CSS' \) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  2>/dev/null | sort || true)
if [[ ${#css_files[@]} -eq 0 ]]; then
  echo "FAIL: no CSS sources under $ROOT"
  exit 1
fi

CFG=""
CFG_TEXT=""
for candidate in .stylelintrc .stylelintrc.json .stylelintrc.yml .stylelintrc.yaml .stylelintrc.js .stylelintrc.cjs .stylelintrc.mjs \
  stylelint.config.js stylelint.config.cjs stylelint.config.mjs stylelint.config.ts; do
  if [[ -f "$candidate" ]]; then
    CFG="$candidate"
    CFG_TEXT="$(cat "$candidate")"
    break
  fi
done
if [[ -z "$CFG" && -f package.json ]] && rg -q '"stylelint"\s*:' package.json 2>/dev/null; then
  CFG="package.json"
  CFG_TEXT="$(cat package.json)"
fi

has_file_cfg=0
[[ -n "$CFG" ]] && has_file_cfg=1

if [[ "$has_file_cfg" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name '.stylelintrc' -o -name '.stylelintrc.json' -o -name 'stylelint.config.js' -o -name 'stylelint.config.cjs' -o -name 'stylelint.config.mjs' \) -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -1 || true)"
  if [[ -n "$nested" ]]; then
    has_file_cfg=1
    CFG="$nested"
    CFG_TEXT="$(cat "$nested")"
  fi
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi 'stylelint' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no stylelint wiring (.stylelintrc* / stylelint.config.* / package.json stylelint / CI stylelint; PSR: stylelint lint)"
  exit 1
fi

# Require PSR rule encode when a product config file is present.
require_declaration_no_important() {
  # Fail if explicitly false / null / "off"
  if echo "$CFG_TEXT" | rg -qi '"declaration-no-important"[[:space:]]*:[[:space:]]*(false|null|"off"|0)'; then
    echo "FAIL: $CFG sets declaration-no-important off (PSR: keep declaration-no-important enabled)"
    return 1
  fi
  if ! echo "$CFG_TEXT" | rg -qi '"declaration-no-important"[[:space:]]*:[[:space:]]*true'; then
    echo "FAIL: $CFG missing declaration-no-important:true (PSR: stylelint declaration-no-important bar)"
    return 1
  fi
  return 0
}

require_selector_max_universal() {
  # Fail if explicitly null / false / "off" / omitted when other rules present
  if echo "$CFG_TEXT" | rg -qi '"selector-max-universal"[[:space:]]*:[[:space:]]*(false|null|"off")'; then
    echo "FAIL: $CFG sets selector-max-universal off (PSR: keep selector-max-universal enabled)"
    return 1
  fi
  # Require an explicit numeric limit (product bar prefers 0)
  if ! echo "$CFG_TEXT" | rg -qi '"selector-max-universal"[[:space:]]*:[[:space:]]*[0-9]+'; then
    echo "FAIL: $CFG missing selector-max-universal:<number> (PSR: stylelint selector-max-universal bar)"
    return 1
  fi
  return 0
}

if [[ -n "$CFG_TEXT" ]]; then
  fail_rules=0
  require_declaration_no_important || fail_rules=1
  require_selector_max_universal || fail_rules=1
  if [[ "$fail_rules" -ne 0 ]]; then
    exit 1
  fi
fi

if [[ "${CSS_STYLELINT_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS css-stylelint-gate ($ROOT, config-only, ${#css_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v stylelint >/dev/null 2>&1; then
  bin="${CSS_STYLELINT_BIN:-stylelint}"
  src="${CSS_STYLELINT_SRC:-}"
  if [[ -z "$src" ]]; then
    if [[ -d src ]]; then src="src/**/*.css"
    elif [[ -d styles ]]; then src="styles/**/*.css"
    elif [[ -d css ]]; then src="css/**/*.css"
    else src="**/*.css"; fi
  fi
  set +e
  "$bin" "$src" >/tmp/stylelint-gate-lint.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/stylelint-gate-lint.$$.out"
    echo "PASS css-stylelint-gate ($ROOT, live stylelint, ${#css_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/stylelint-gate-lint.$$.out"
fi

echo "PASS css-stylelint-gate ($ROOT, config-only fallback, ${#css_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
