#!/usr/bin/env bash
# Tier 1a: require Credo wiring (PSR Elixir language-farm).
# Does not run the analyzer (host/deps dependent); proves .credo.exs and/or
# credo mix dep / CI encode Credo. Escape: ELIXIR_CREDO_GATE_SKIP=1.
# Usage: bash scripts/elixir-credo-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${ELIXIR_CREDO_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS elixir-credo-gate (skipped via ELIXIR_CREDO_GATE_SKIP=1)"
  exit 0
fi

found=0

# Config files
for f in .credo.exs credo.exs; do
  if [[ -f "$f" ]]; then found=1; fi
done

# Nested configs
if [[ "$found" -eq 0 ]]; then
  if find . -maxdepth 3 -type f \( -name '.credo.exs' -o -name 'credo.exs' \) \
      -not -path '*/deps/*' -not -path '*/_build/*' -not -path '*/.git/*' 2>/dev/null \
      | head -1 | rg -q .; then
    found=1
  fi
fi

# mix.exs / mix.lock credo dep
if [[ -f mix.exs ]] && rg -qi '\bcredo\b' mix.exs 2>/dev/null; then found=1; fi
if [[ -f mix.lock ]] && rg -qi '\bcredo\b' mix.lock 2>/dev/null; then found=1; fi

# CI mentions
if [[ "$found" -eq 0 ]] && [[ -d .github/workflows ]]; then
  if rg -qi 'mix[[:space:]]+credo|\bcredo\b' .github/workflows 2>/dev/null; then
    found=1
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no Credo wiring (.credo.exs / credo mix dep / CI mix credo; PSR language-farm requires Credo)"
  exit 1
fi
echo "PASS elixir-credo-gate ($ROOT)"
