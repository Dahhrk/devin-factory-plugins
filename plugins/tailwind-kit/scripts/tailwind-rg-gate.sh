#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Tailwind smells (portable regex bar).
# PSR: tailwindcss wiring; no @apply overuse; no arbitrary-value sprawl;
# no safelist abuse; no content-path miss / purge footguns.
# Language-farm. Product Tailwind build remains authoritative for depth; this
# gate is the portable rg bar for Tailwind trust / purge / design-token smells.
#
# Usage: bash scripts/tailwind-rg-gate.sh [root] [path ...]
# Default scan: TAILWIND_RG_SRC or . Escape hatch: tailwind-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for tailwind-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${TAILWIND_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${TAILWIND_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(apply_overuse arbitrary_sprawl safelist_abuse content_path_miss)
SCAN_PATS=(
  '(?i)@apply\b'
  '(?:[\w:-]+-\[[^\]]+\]|\[[a-z][\w-]*:[^\]]+\])'
  '(?i)(\bsafelist\s*:)|(@source\s+inline\s*\()'
  '(?i)(content\s*:\s*\[\s*\])|(class(?:Name)?\s*=\s*\{?[^;}\n]*[\x22\x27\x60][a-z][\w-]*-[\x22\x27\x60]\s*\+)|(class(?:Name)?\s*=\s*[\x22\x27\x60][^\x22\x27\x60\n]*[\x22\x27\x60]\s*\+)'
)
CLASS_PATS=(
  '(?i)@apply\b'
  '(?:[\w:-]+-\[[^\]]+\]|\[[a-z][\w-]*:[^\]]+\])'
  '(?i)(\bsafelist\s*:)|(@source\s+inline\s*\()'
  '(?i)(content\s*:\s*\[\s*\])|(class(?:Name)?\s*=\s*\{?[^;}\n]*[\x22\x27\x60][a-z][\w-]*-[\x22\x27\x60]\s*\+)|(class(?:Name)?\s*=\s*[\x22\x27\x60][^\x22\x27\x60\n]*[\x22\x27\x60]\s*\+)'
)
MSGS=(
  '@apply overuse banned (prefer utilities / components; tailwind-rg-allow with rationale)'
  'Arbitrary-value sprawl banned (util-[…] / [prop:…]; prefer theme tokens; tailwind-rg-allow with rationale)'
  'Safelist abuse banned (safelist: / @source inline(…); prefer content/@source paths; tailwind-rg-allow with rationale)'
  'Content-path miss / purge footgun banned (content: [] / dynamic class concat; prefer complete classes + content/@source; tailwind-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.css' --glob '*.CSS'
  --glob '*.html' --glob '*.HTML'
  --glob '*.js' --glob '*.jsx' --glob '*.ts' --glob '*.tsx'
  --glob '*.vue' --glob '*.svelte' --glob '*.astro' --glob '*.mdx'
  --glob 'tailwind.config.js' --glob 'tailwind.config.cjs' --glob 'tailwind.config.mjs' --glob 'tailwind.config.ts'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and CSS/HTML/JS comment-only hits (line is only a comment).
  rg -v 'tailwind-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(/\*|//|<!--)' >"$FILT" || true
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
echo "PASS tailwind-rg-gate (${TARGETS[*]}, single-walk)"
