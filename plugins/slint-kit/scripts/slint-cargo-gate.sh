#!/usr/bin/env bash
# Tier 1: require Slint build wiring (PSR Slint language-farm).
# Portable bar: .slint present + Cargo.toml/build.rs/CI mentioning slint / slint-build,
# or CMakeLists mentioning Slint.
# Escape: SLINT_CARGO_GATE_SKIP=1.
# Usage: bash scripts/slint-cargo-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${SLINT_CARGO_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS slint-cargo-gate (skipped via SLINT_CARGO_GATE_SKIP=1)"
  exit 0
fi

mapfile -t slint_files < <(find . \( \
  -name '*.slint' -o -name '*.SLINT' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/target/*' -not -path '*/build/*' \
  -not -path '*/testdata/*' -not -path '*/tests/*' -not -path '*/Tests/*' \
  -not -path '*/examples/*' -not -path '*/example/*' \
  2>/dev/null | sort || true)
if [[ ${#slint_files[@]} -eq 0 ]]; then
  echo "FAIL: no Slint (.slint) sources under $ROOT"
  exit 1
fi

has_wiring=0
CFG=""
if [[ -f Cargo.toml ]] && rg -qi '\bslint(-build)?\b' Cargo.toml 2>/dev/null; then
  has_wiring=1
  CFG="Cargo.toml"
fi
if [[ -f build.rs ]] && rg -qi '\bslint(_build)?\b|slint-build' build.rs 2>/dev/null; then
  has_wiring=1
  CFG="${CFG:+$CFG+}build.rs"
fi
for mf in CMakeLists.txt cmake/FindSlint.cmake; do
  if [[ -f "$mf" ]] && rg -qi '\bSlint\b|\bslint\b' "$mf" 2>/dev/null; then
    has_wiring=1
    CFG="$mf"
    break
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi '\bslint\b|slint-build|cargo (build|test|check)' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no slint wiring (Cargo.toml/build.rs/CMake mentioning slint; or CI with cargo/slint; PSR: Slint toolchain)"
  exit 1
fi

if [[ "${SLINT_CARGO_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS slint-cargo-gate ($ROOT, config-only, ${#slint_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v cargo >/dev/null 2>&1; then
  live_rc=0
fi

echo "PASS slint-cargo-gate ($ROOT, config-only fallback, ${#slint_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
