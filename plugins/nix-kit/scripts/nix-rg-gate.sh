#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Nix smells (portable regex bar).
# PSR: no fetchurl without hash; no builtins.exec / IFD abuse; no impure env
# lookups; no world-writable store paths in recipes; no curl|bash in builders.
# Language-farm. Product nix flake check / statix / alejandra remains
# authoritative; this gate is the portable rg bar for Nix trust smells.
#
# Usage: bash scripts/nix-rg-gate.sh [root] [path ...]
# Default scan: NIX_RG_SRC or . Escape hatch: nix-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.nix / flake.nix / default.nix / shell.nix.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for nix-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${NIX_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${NIX_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# fetchurl_no_hash: fetchurl/fetchTarball/fetchzip without hash/sha256/outputHash on same line
# builtins_exec_ifd: builtins.exec or classic IFD import(fetch)/readFile(fetch|runCommand|…)
# impure_env: builtins.getEnv
# world_writable: chmod 777 / a+w / umask 000
# curl_bash: curl|bash / wget|sh
IDS=(fetchurl_no_hash builtins_exec_ifd impure_env world_writable curl_bash)
SCAN_PATS=(
  '(?i)(?:builtins\.)?fetch(?:url|Tarball|zip)\b(?![^\n]*(?:sha256|hash|outputHash)\s*=)'
  '(?i)builtins\.exec\b|(?i)import\s*\(\s*(?:pkgs\.)?(?:fetch(?:url|Tarball|zip|FromGitHub|git|gitPrivate)|builtins\.fetch)|(?i)builtins\.readFile\s+\(?\s*(?:pkgs\.)?(?:fetch|runCommand|stdenv\.mkDerivation|derivation)\b'
  '(?i)builtins\.getEnv\b'
  '(?i)chmod\s+(?:-R\s+)?(?:[0-7]*777\b|a\+w\b|ugo\+w\b)|(?i)umask\s+0+\b'
  '(?i)(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)
CLASS_PATS=(
  '(?i):[0-9]+:.*(?:builtins\.)?fetch(?:url|Tarball|zip)\b(?![^\n]*(?:sha256|hash|outputHash)\s*=)'
  '(?i):[0-9]+:.*builtins\.exec\b|(?i):[0-9]+:.*import\s*\(\s*(?:pkgs\.)?(?:fetch(?:url|Tarball|zip|FromGitHub|git|fetchgit|gitPrivate)|builtins\.fetch)|(?i):[0-9]+:.*builtins\.readFile\s+\(?\s*(?:pkgs\.)?(?:fetch|runCommand|stdenv\.mkDerivation|derivation)\b'
  '(?i):[0-9]+:.*builtins\.getEnv\b'
  '(?i):[0-9]+:.*chmod\s+(?:-R\s+)?(?:[0-7]*777\b|a\+w\b|ugo\+w\b)|(?i):[0-9]+:.*umask\s+0+\b'
  '(?i):[0-9]+:.*(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)

MSGS=(
  'fetchurl without hash banned (fetchurl/fetchTarball/fetchzip without hash|sha256|outputHash on the same line; prefer SRI hash = "sha256-..."; nix-rg-allow with rationale)'
  'builtins.exec / IFD abuse banned (builtins.exec or import(fetch…)/builtins.readFile(fetch|runCommand|…); prefer pure evaluation; nix-rg-allow with rationale)'
  'impure env lookups banned (builtins.getEnv; prefer flake inputs / explicit args; nix-rg-allow with rationale)'
  'world-writable store paths banned (chmod 777 / chmod a+w / umask 000 in builders; prefer 755/644; nix-rg-allow with rationale)'
  'curl|bash banned (curl|bash / wget|sh pipe-to-shell in builders; prefer checksummed ./scripts/install.sh; nix-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.nix'
  --glob '**/flake.nix' --glob '**/default.nix' --glob '**/shell.nix'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure comment lines (# nix comments).
  rg -v 'nix-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*#' >"$FILT" || true
else
  : >"$FILT"
fi

report_fail() {
  echo "FAIL: $1"
  head -40 "$2"
  local n; n=$(wc -l <"$2" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
}

classify_one() {
  local i="$1" id="${IDS[$i]}" cpat="${CLASS_PATS[$i]}"
  local hitfile="$TMPDIR_GATE/hit.$id" rcfile="$TMPDIR_GATE/rc.$id"
  : >"$hitfile"
  rg -P -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
  if [[ -s "$hitfile" ]]; then echo 1 >"$rcfile"; else echo 0 >"$rcfile"; fi
}

if [[ -s "$FILT" ]]; then
  pids=()
  for i in "${!IDS[@]}"; do classify_one "$i" & pids+=($!); done
  for pid in "${pids[@]}"; do wait "$pid" || true; done
  for i in "${!IDS[@]}"; do
    if [[ "$(cat "$TMPDIR_GATE/rc.${IDS[$i]}")" != "0" ]]; then
      report_fail "${MSGS[$i]}" "$TMPDIR_GATE/hit.${IDS[$i]}"
      fail=1
    fi
  done
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS nix-rg-gate (${TARGETS[*]}, single-walk)"
