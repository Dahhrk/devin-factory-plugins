#!/usr/bin/env bash
# Tier 0.5b: Clippy wired (PSR: Clippy).
# Require clippy.toml / [lints.clippy] in Cargo.toml / cargo clippy in CI.
# Live `cargo clippy` when available unless RUST_CLIPPY_CONFIG_ONLY=1.
# Usage: bash scripts/rust-clippy-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

fail=0
found=0

if [[ -f clippy.toml ]] || [[ -f .clippy.toml ]]; then found=1; fi
if [[ -f Cargo.toml ]] && rg -q '\[lints\.clippy\]|clippy::' Cargo.toml 2>/dev/null; then found=1; fi

check_ci() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if rg -q 'cargo[[:space:]]+clippy|clippy[[:space:]]+--' "$f" 2>/dev/null; then found=1; fi
}
check_ci Makefile
if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_ci "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no Clippy wiring (clippy.toml / [lints.clippy] / cargo clippy in CI); copy rust-kit/templates/clippy/clippy.toml"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi

if [[ "${RUST_CLIPPY_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS rust-clippy-gate ($ROOT, config-only)"
  exit 0
fi

if command -v cargo >/dev/null 2>&1 && cargo clippy --help >/dev/null 2>&1; then
  cargo clippy --all-targets -- -D warnings
  echo "PASS rust-clippy-gate ($ROOT, live)"
  exit 0
fi

echo "PASS rust-clippy-gate ($ROOT, wiring-only; install clippy for live)"
