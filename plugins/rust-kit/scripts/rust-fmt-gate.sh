#!/usr/bin/env bash
# Tier 0.5a: rustfmt clean (PSR: rustfmt).
# Live `cargo fmt --all --check` or `rustfmt --check` when tools exist.
# Otherwise require rustfmt.toml (config presence). Force config-only:
# RUST_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/rust-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . -name '*.rs' -not -path '*/target/*' -not -path '*/.git/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no .rs files under $ROOT"
  exit 1
fi

has_cfg=0
[[ -f rustfmt.toml ]] && has_cfg=1
[[ -f .rustfmt.toml ]] && has_cfg=1

if [[ "${RUST_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS rust-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no rustfmt.toml (copy rust-kit/templates/rustfmt.toml); or unset RUST_FMT_CONFIG_ONLY"
  exit 1
fi

if command -v cargo >/dev/null 2>&1 && cargo fmt --help >/dev/null 2>&1; then
  cargo fmt --all -- --check
  echo "PASS rust-fmt-gate ($ROOT, live cargo fmt, ${#files[@]} files)"
  exit 0
fi

if command -v rustfmt >/dev/null 2>&1; then
  rustfmt --check "${files[@]}"
  echo "PASS rust-fmt-gate ($ROOT, live rustfmt, ${#files[@]} files)"
  exit 0
fi

# No live tool: config presence is the portable bar (CI still runs live).
if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS rust-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install rustfmt for live)"
  exit 0
fi

echo "FAIL: rustfmt/cargo-fmt not on PATH and no rustfmt.toml (PSR: rustfmt)"
exit 1
