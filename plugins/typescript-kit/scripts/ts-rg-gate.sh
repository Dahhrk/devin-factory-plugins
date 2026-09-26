#!/usr/bin/env bash
# Tier 0: PSR TypeScript smells (any/assertions, DOM !, JSON.parse, global
# fetch/URL/env, double assertion, bare @ts-expect-error).
# Usage: bash scripts/ts-rg-gate.sh [root]
# Scan: TS_RG_SRC or src|lib|app. Escape: ts-rg-allow.
# .d.ts: product scans; TS_RG_SKIP_DTS=1 for library host research.
# fetch: global fetch( only (method .fetch allowed).
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for ts-rg-gate"
  exit 1
fi

pick_src() {
  if [[ -n "${TS_RG_SRC:-}" ]]; then echo "$TS_RG_SRC"; return; fi
  for candidate in src lib app; do
    [[ -d "$candidate" ]] && { echo "$candidate"; return; }
  done
  echo ""
}

SRC="$(pick_src)"
if [[ -z "$SRC" || ! -d "$SRC" ]]; then
  echo "FAIL: expected source dir src (or lib/app); set TS_RG_SRC (root=$ROOT)"
  exit 1
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

SKIP_DTS=0
case "${TS_RG_SKIP_DTS:-}" in 1|true|TRUE|yes|YES) SKIP_DTS=1 ;; esac

IDS=(asany colonany genany anyarr promiseany recordany tsignore tsnocheck unknownas tsexpect domid domqs jsonparse fetch newurl processenv)
PATS=(
  '\bas\s+any\b' ':\s*any\b' '<any>' '\bany\[' '\bPromise\s*<\s*any\s*>'
  '\bRecord\s*<\s*[^,]+,\s*any\s*>' '@ts-ignore\b' '@ts-nocheck\b'
  '\bas\s+unknown\s+as\b' '@ts-expect-error\b'
  'getElementById\s*\([^)]*\)\s*!' 'querySelector(All)?\s*\([^)]*\)\s*!'
  '\bJSON\.parse\s*\(' '(^|[^.\w])fetch\s*\(' '\bnew\s+URL\s*\('
  '\bprocess\.env(?:\.\w+|\[)'
)
MSGS=(
  'as any banned' 'explicit : any banned' 'generic any banned' 'any[] banned'
  'Promise<any> banned' 'Record<*, any> banned'
  '@ts-ignore banned (prefer typed fix or @ts-expect-error with description via oxlint)'
  '@ts-nocheck banned'
  'as unknown as banned (prefer named parse / satisfies; ts-rg-allow with rationale)'
  '@ts-expect-error requires a trailing description (e.g. // @ts-expect-error - reason)'
  'DOM non-null: getElementById(...)! banned; check null then use narrowed node'
  'DOM non-null: querySelector*(...)! banned; check null then use narrowed node'
  'JSON.parse in src banned without a typed parse boundary (move behind a named parser or schema; ts-rg-allow on the parser line if needed)'
  'fetch in src banned without a named boundary (parse Response into a domain type; ts-rg-allow on the boundary line; method .fetch is allowed)'
  'new URL in src banned without a named boundary (validate input; ts-rg-allow on the boundary line)'
  'process.env in src banned without a named env parse boundary (ts-rg-allow on the parser line; whole-object process.env to a schema is OK)'
)
DROPS=('' '' '' '' '' '' '' '' '' '@ts-expect-error\s+\S' '' '' '' '' '' '')

PAT_ARGS=()
for pat in "${PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.ts' --glob '*.tsx' --glob '*.mts' --glob '*.cts'
  --glob '!**/node_modules/**' --glob '!**/.git/**' )
if [[ "$SKIP_DTS" -eq 1 ]]; then
  rg_globs+=( --glob '!*.d.ts' --glob '!*.d.mts' --glob '!*.d.cts' )
fi

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "$SRC" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'ts-rg-allow' "$ALL" >"$FILT" || true
else
  : >"$FILT"
fi

report_fail() {
  echo "FAIL: $1"
  head -40 "$2"
  local n; n=$(wc -l <"$2" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
  return 0
}

classify_one() {
  local i="$1" id="${IDS[$i]}" pat="${PATS[$i]}" drop="${DROPS[$i]}"
  local hitfile="$TMPDIR_GATE/hit.$id" rcfile="$TMPDIR_GATE/rc.$id"
  : >"$hitfile"
  rg -- "$pat" "$FILT" >"$hitfile" 2>/dev/null || true
  if [[ -n "$drop" && -s "$hitfile" ]]; then
    rg -v -- "$drop" "$hitfile" >"$TMPDIR_GATE/drop.$id" || true
    mv "$TMPDIR_GATE/drop.$id" "$hitfile"
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
mode="product"; [[ "$SKIP_DTS" -eq 1 ]] && mode="library (TS_RG_SKIP_DTS=1)"
echo "PASS ts-rg-gate ($ROOT/$SRC, $mode, single-walk)"
