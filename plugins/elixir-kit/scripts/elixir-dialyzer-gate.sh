#!/usr/bin/env bash
# Tier 1b: require dialyzer / dialyxir wiring (PSR Elixir language-farm).
# Does not run dialyzer (PLT/host dependent); proves dialyxir dep and/or
# mix dialyzer / CI. Escape: ELIXIR_DIALYZER_GATE_SKIP=1.
# Usage: bash scripts/elixir-dialyzer-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${ELIXIR_DIALYZER_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS elixir-dialyzer-gate (skipped via ELIXIR_DIALYZER_GATE_SKIP=1)"
  exit 0
fi

found=0

# Ignore / config markers
for f in .dialyzer_ignore.exs dialyzer.exs; do
  if [[ -f "$f" ]]; then found=1; fi
done

# mix.exs dialyxir / dialyzer project key
if [[ -f mix.exs ]]; then
  if rg -qi 'dialyxir|\bdialyzer\b' mix.exs 2>/dev/null; then found=1; fi
fi
if [[ -f mix.lock ]] && rg -qi 'dialyxir' mix.lock 2>/dev/null; then found=1; fi

# CI mentions
if [[ "$found" -eq 0 ]] && [[ -d .github/workflows ]]; then
  if rg -qi 'mix[[:space:]]+dialyzer|\bdialyxir\b|\bdialyzer\b' .github/workflows 2>/dev/null; then
    found=1
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no dialyzer wiring (dialyxir dep / mix dialyzer / CI; PSR language-farm requires dialyzer)"
  exit 1
fi
echo "PASS elixir-dialyzer-gate ($ROOT)"
