#!/usr/bin/env bash
# Tier 0.5: ShellCheck clean (PSR: ShellCheck).
# Live shellcheck on *.sh / *.bash unless SH_SHELLCHECK_CONFIG_ONLY=1 (then only
# require .shellcheckrc or shellcheck directive presence).
# Usage: bash scripts/sh-shellcheck-gate.sh [root] [path ...]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
else
  TARGETS=(.)
fi

mapfile -t files < <(
  find "${TARGETS[@]}" \( -name '*.sh' -o -name '*.bash' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | sort || true
)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no .sh/.bash files under ${TARGETS[*]}"
  exit 1
fi

if [[ "${SH_SHELLCHECK_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ -f .shellcheckrc ]] || [[ -f shellcheckrc ]]; then
    echo "PASS sh-shellcheck-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no .shellcheckrc (copy shell-kit/templates/shellcheck/shellcheckrc); or unset SH_SHELLCHECK_CONFIG_ONLY"
  exit 1
fi

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "FAIL: shellcheck not on PATH (install ShellCheck, or set SH_SHELLCHECK_CONFIG_ONLY=1)"
  exit 1
fi

# Severity: error+warning fail the gate; style/info remain advisory unless product tightens.
shellcheck -S warning -x "${files[@]}"
echo "PASS sh-shellcheck-gate (${#files[@]} files, live)"
