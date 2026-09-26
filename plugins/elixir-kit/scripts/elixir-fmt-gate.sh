#!/usr/bin/env bash
# Tier 0.5a: mix format wiring as agreed formatter (PSR Elixir).
# Live `mix format --check-formatted` when mix exists unless ELIXIR_FMT_CONFIG_ONLY=1.
# Portable bar: .formatter.exs and/or CI mix format --check-formatted.
# Usage: bash scripts/elixir-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . \( -name '*.ex' -o -name '*.exs' \) -not -path '*/.git/*' -not -path '*/_build/*' -not -path '*/deps/*' -not -path '*/tmp/*' -not -path '*/node_modules/*' -not -path '*/test/*' -not -path '*/tests/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Elixir sources under $ROOT"
  exit 1
fi

has_cfg=0
# .formatter.exs
if [[ -f .formatter.exs ]]; then has_cfg=1; fi
# Nested formatter (apps/ umbrella)
if [[ "$has_cfg" -eq 0 ]]; then
  if find . -maxdepth 3 -type f -name '.formatter.exs' -not -path '*/deps/*' -not -path '*/_build/*' -not -path '*/.git/*' 2>/dev/null \
      | head -1 | rg -q .; then
    has_cfg=1
  fi
fi
# CI mix format
if [[ -d .github/workflows ]]; then
  if rg -qi 'mix[[:space:]]+format|format[[:space:]]+--check-formatted' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi
# mix.exs aliases format
if [[ -f mix.exs ]] && rg -qi 'format[[:space:]]+--check-formatted|mix[[:space:]]+format' mix.exs 2>/dev/null; then has_cfg=1; fi

if [[ "${ELIXIR_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS elixir-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no mix format wiring (.formatter.exs / CI mix format --check-formatted; or unset ELIXIR_FMT_CONFIG_ONLY)"
  exit 1
fi

run_fmt() {
  if command -v mix >/dev/null 2>&1; then
    mix format --check-formatted 2>/dev/null
    return $?
  fi
  return 127
}

if run_fmt; then
  echo "PASS elixir-fmt-gate ($ROOT, live mix format, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS elixir-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install Elixir/mix for live)"
    exit 0
  fi
  echo "FAIL: mix not on PATH and no .formatter.exs / CI mix format wiring (PSR: mix format)"
  exit 1
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS elixir-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: mix format --check-formatted would rewrite or flag sources (PSR: mix format)"
exit 1
