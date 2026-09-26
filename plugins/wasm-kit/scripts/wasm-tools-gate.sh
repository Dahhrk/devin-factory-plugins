#!/usr/bin/env bash
# Tier 1: require wat/wasm tooling wiring (PSR Wasm language-farm).
# Portable bar: .wat/.wast/.wasm present + Makefile/Cargo/package.json/CI
# mentioning wat2wasm / wasm-tools / wabt / wasm-as / wasm-opt / wasmati.
# Escape: WASM_TOOLS_GATE_SKIP=1.
# Usage: bash scripts/wasm-tools-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${WASM_TOOLS_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS wasm-tools-gate (skipped via WASM_TOOLS_GATE_SKIP=1)"
  exit 0
fi

mapfile -t wasm_files < <(find . \( \
  -name '*.wat' -o -name '*.wast' -o -name '*.WAT' -o -name '*.WAST' -o -name '*.wasm' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/target/*' -not -path '*/build/*' \
  -not -path '*/testdata/*' -not -path '*/tests/*' -not -path '*/Tests/*' \
  -not -path '*/examples/*' -not -path '*/example/*' \
  2>/dev/null | sort || true)
if [[ ${#wasm_files[@]} -eq 0 ]]; then
  echo "FAIL: no Wasm (.wat/.wast/.wasm) sources under $ROOT"
  exit 1
fi

WIRE_PAT='wat2wasm|wasm2wat|wasm-tools|wabt|wasm-as|wasm-opt|wasmati|wasmtime|wasm-pack'
has_wiring=0
CFG=""
for mf in Makefile makefile GNUmakefile Cargo.toml package.json; do
  if [[ -f "$mf" ]] && rg -qiP "$WIRE_PAT" "$mf" 2>/dev/null; then
    has_wiring=1
    CFG="$mf"
    break
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP "$WIRE_PAT|wasm" .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no wat/wasm tooling wiring (Makefile/Cargo/package.json mentioning wat2wasm|wasm-tools|wabt|wasm-as|wasm-opt|wasmati; or CI with wasm tooling; PSR: Wasm toolchain)"
  exit 1
fi

if [[ "${WASM_TOOLS_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS wasm-tools-gate ($ROOT, config-only, ${#wasm_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v wat2wasm >/dev/null 2>&1 || command -v wasm-tools >/dev/null 2>&1; then
  live_rc=0
fi

echo "PASS wasm-tools-gate ($ROOT, config-only fallback, ${#wasm_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
