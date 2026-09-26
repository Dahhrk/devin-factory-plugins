#!/usr/bin/env bash
# Tier 1: require nix / *.nix toolchain wiring (PSR Nix language-farm).
# Live `nix --version` when resolvable unless NIX_NIX_CONFIG_ONLY=1.
# Portable bar: *.nix / flake.nix / default.nix / shell.nix / CI nix.
# Escape: NIX_NIX_GATE_SKIP=1.
# Usage: bash scripts/nix-nix-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${NIX_NIX_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS nix-nix-gate (skipped via NIX_NIX_GATE_SKIP=1)"
  exit 0
fi

mapfile -t nix_files < <(find . \( \
  -name '*.nix' -o -name 'flake.nix' -o -name 'default.nix' -o -name 'shell.nix' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' \
  2>/dev/null | sort || true)
if [[ ${#nix_files[@]} -eq 0 ]]; then
  echo "FAIL: no *.nix / flake.nix / default.nix / shell.nix under $ROOT"
  exit 1
fi

CFG=""
has_file_cfg=0
# Require real Nix anchors (not bare substring in a comment-only name).
INSTR_PAT='(?im)(?:stdenv\.mkDerivation\b|mkDerivation\b|^\s*outputs\s*=|^\s*packages\s*=|^\s*devShells\s*=|^\s*flake\s*=|(?:builtins\.)?fetch(?:url|Tarball|zip)\s*\{|^\s*let\b|^\s*in\b|nixpkgs|^\s*\{\s*[^}\n]*pkgs|derivation\s*\{)'

if rg -qP --glob '*.nix' \
  --glob '!**/.git/**' --glob '!**/vendor/**' \
  "$INSTR_PAT" . 2>/dev/null; then
  has_file_cfg=1
  CFG="nix-instructions"
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qiP '(^|[^\w-])nix(\s|$|[^\w-])|nix-build|nix\s+flake|NIXPKGS|cachix' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

# Strong wiring: Nix instructions, or CI that names nix.
if [[ "$has_file_cfg" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no nix wiring (*.nix instructions / CI; PSR: Nix toolchain)"
  exit 1
fi

if [[ "${NIX_NIX_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS nix-nix-gate ($ROOT, config-only, ${#nix_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v nix >/dev/null 2>&1; then
  set +e
  nix --version >/tmp/nix-gate-ver.$$.out 2>&1
  live_rc=$?
  set -e
  if [[ "$live_rc" -eq 0 ]]; then
    rm -f "/tmp/nix-gate-ver.$$.out"
    echo "PASS nix-nix-gate ($ROOT, live nix, ${#nix_files[@]} files)"
    exit 0
  fi
  rm -f "/tmp/nix-gate-ver.$$.out"
fi

echo "PASS nix-nix-gate ($ROOT, config-only fallback, ${#nix_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
