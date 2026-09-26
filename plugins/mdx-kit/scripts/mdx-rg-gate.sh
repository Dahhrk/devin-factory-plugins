#!/usr/bin/env bash
# Tier 0: Programming Standards Reference MDX smells (portable regex bar).
# PSR: @mdx-js wiring; no raw HTML injection; no untrusted JSX evaluate;
# no rehype/remark plugin footguns (rehype-raw without sanitize).
# Language-farm. Product MDX toolchain remains authoritative for compile;
# this gate is the portable rg bar for MDX trust smells.
#
# Usage: bash scripts/mdx-rg-gate.sh [root] [path ...]
# Default scan: MDX_RG_SRC or . Escape hatch: mdx-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.mdx and pipeline JS/TS.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for mdx-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${MDX_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${MDX_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
IDS=(raw_html_injection untrusted_jsx_eval rehype_raw_unsanitized)
SCAN_PATS=(
  '(?i)\bdangerouslySetInnerHTML\b'
  '(?i)\bevaluate(Sync)?\s*\('
  '(?i)\brehypeRaw\b|[''"]rehype-raw[''"]'
)
CLASS_PATS=(
  '(?i)\bdangerouslySetInnerHTML\b'
  '(?i)\bevaluate(Sync)?\s*\('
  '(?i)\brehypeRaw\b|[''"]rehype-raw[''"]'
)
MSGS=(
  'raw HTML injection banned (dangerouslySetInnerHTML; prefer MDX/JSX children or sanitized markdown; mdx-rg-allow with rationale)'
  'untrusted JSX in MDX banned (evaluate/evaluateSync of dynamic MDX; prefer static .mdx imports from trusted authors; mdx-rg-allow with rationale)'
  'rehype/remark plugin footgun banned (rehype-raw / rehypeRaw without rehype-sanitize / rehypeSanitize in the same file; mdx-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.mdx' --glob '*.MDX'
  --glob '*.js' --glob '*.jsx' --glob '*.mjs' --glob '*.cjs' --glob '*.ts' --glob '*.tsx'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (line is only a // or {/* or <!-- comment).
  rg -v 'mdx-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|/\*|/\{\*|<!--|\*)' >"$FILT" || true
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
  # rehype-raw: drop hits when the same source file also mentions rehype-sanitize
  if [[ "$id" == "rehype_raw_unsanitized" && -s "$hitfile" ]]; then
    local kept="$TMPDIR_GATE/hit.rehype_raw_unsanitized.kept"
    : >"$kept"
    while IFS= read -r line || [[ -n "$line" ]]; do
      local fpath="${line%%:*}"
      if [[ -f "$fpath" ]] && rg -qiP 'rehypeSanitize|[''"]rehype-sanitize[''"]' "$fpath" 2>/dev/null; then
        continue
      fi
      printf '%s\n' "$line" >>"$kept"
    done <"$hitfile"
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
echo "PASS mdx-rg-gate (${TARGETS[*]}, single-walk)"
