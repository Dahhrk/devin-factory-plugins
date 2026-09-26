#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Astro smells (portable regex bar).
# PSR: astro check/build wiring; no client:load abuse; no set:html without
# sanitize; no define:vars XSS smells.
# Language-farm. Product astro remains authoritative for check/build; this gate
# is the portable rg bar for Astro trust smells.
#
# Usage: bash scripts/astro-rg-gate.sh [root] [path ...]
# Default scan: ASTRO_RG_SRC or . Escape hatch: astro-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.astro.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for astro-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${ASTRO_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${ASTRO_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
# set:html is scanned broadly then filtered to "without sanitize" in classify.
IDS=(client_load set_html_raw define_vars)
SCAN_PATS=(
  '(?i)\bclient:load\b'
  '(?i)\bset:html\b'
  '(?i)\bdefine:vars\b'
)
CLASS_PATS=(
  '(?i)\bclient:load\b'
  '(?i)\bset:html\b'
  '(?i)\bdefine:vars\b'
)
MSGS=(
  'client:load abuse banned (prefer client:visible / client:idle / client:media / static HTML; astro-rg-allow with rationale)'
  'set:html without sanitize banned (prefer auto-escaped {expr} or DOMPurify.sanitize / sanitizeHtml / .sanitize( on the same line; astro-rg-allow with rationale)'
  'define:vars XSS smell banned (prefer data-* attributes + module scripts; define:vars inlines into <script>; astro-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.astro' --glob '*.ASTRO' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (line is only a // or <!-- comment).
  rg -v 'astro-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|<!--)' >"$FILT" || true
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
  # set:html: drop lines that sanitize on the same attribute line
  if [[ "$id" == "set_html_raw" && -s "$hitfile" ]]; then
    local kept="$TMPDIR_GATE/hit.set_html_raw.kept"
    rg -v -P '(?i)(DOMPurify\.sanitize|sanitizeHtml|\.sanitize\s*\(|(?<![\w.])sanitize\s*\()' "$hitfile" >"$kept" 2>/dev/null || true
    mv "$kept" "$hitfile"
  fi
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
echo "PASS astro-rg-gate (${TARGETS[*]}, single-walk)"
