#!/usr/bin/env bash
# Tier 0: Programming Standards Reference TypeScript smells (any/assertions,
# DOM non-null, bare JSON.parse, fetch/URL/env boundaries, double assertion,
# bare @ts-expect-error).
# Product oxlint/tsc remain authoritative for typed depth; this gate is the
# portable regex bar.
#
# Usage: bash scripts/ts-rg-gate.sh [root]
# Default scan dir: src (override with TS_RG_SRC). When src is missing, tries
# lib then app before failing.
# Escape hatch: ts-rg-allow on the line.
#
# .d.ts product-vs-library policy:
#   Product (default): scan *.d.ts. Public product types must not expose : any.
#   Library research: TS_RG_SKIP_DTS=1 skips declaration files (host plugin /
#   parser APIs often need any). Prefer named allow on a line when only one
#   site is intentional.
#
# fetch: matches global fetch( only — not method .fetch( (tRPC / React Query).
# Hot-path: one shared file walk setup; smell checks run concurrently.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

pick_src() {
  if [[ -n "${TS_RG_SRC:-}" ]]; then
    echo "$TS_RG_SRC"
    return
  fi
  for candidate in src lib app; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  echo ""
}

SRC="$(pick_src)"
if [[ -z "$SRC" ]]; then
  echo "FAIL: expected source dir src (or lib/app); set TS_RG_SRC to override (root=$ROOT)"
  exit 1
fi
if [[ ! -d "$SRC" ]]; then
  echo "FAIL: source dir '$SRC' missing under $ROOT (set TS_RG_SRC to override)"
  exit 1
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT

SKIP_DTS=0
case "${TS_RG_SKIP_DTS:-}" in
  1|true|TRUE|yes|YES) SKIP_DTS=1 ;;
esac

HAS_RG=0
if command -v rg >/dev/null 2>&1; then HAS_RG=1; fi

rg_globs=()
if [[ "$HAS_RG" -eq 1 ]]; then
  rg_globs=( --glob '*.ts' --glob '*.tsx' --glob '*.mts' --glob '*.cts'
    --glob '!**/node_modules/**' --glob '!**/.git/**' )
  if [[ "$SKIP_DTS" -eq 1 ]]; then
    rg_globs+=( --glob '!*.d.ts' --glob '!*.d.mts' --glob '!*.d.cts' )
  fi
fi

# Emit raw hits for pat into hitfile (no allow filter yet).
scan() {
  local pat="$1" hitfile="$2"
  : >"$hitfile"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -n "${rg_globs[@]}" -e "$pat" "$SRC" >"$hitfile" 2>/dev/null || true
  else
    local find_expr=( "$SRC" \( -name '*.ts' -o -name '*.tsx' -o -name '*.mts' -o -name '*.cts' \) )
    if [[ "$SKIP_DTS" -eq 1 ]]; then
      find_expr+=( ! -name '*.d.ts' ! -name '*.d.mts' ! -name '*.d.cts' )
    fi
    find "${find_expr[@]}" ! -path '*/node_modules/*' ! -path '*/.git/*' -print0 2>/dev/null \
      | xargs -0 grep -nE "$pat" >"$hitfile" 2>/dev/null || true
  fi
}

# Drop ts-rg-allow lines; optionally drop lines matching keep_pat (inverse filter).
filter_hits() {
  local hitfile="$1" filtered="$2" drop_described="${3:-}"
  if [[ ! -s "$hitfile" ]]; then
    : >"$filtered"
    return 0
  fi
  local tmp="$filtered.raw"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -v 'ts-rg-allow' "$hitfile" >"$tmp" || true
  else
    grep -v 'ts-rg-allow' "$hitfile" >"$tmp" || true
  fi
  if [[ -n "$drop_described" ]]; then
    if [[ "$HAS_RG" -eq 1 ]]; then
      rg -v "$drop_described" "$tmp" >"$filtered" || true
    else
      grep -vE "$drop_described" "$tmp" >"$filtered" || true
    fi
    rm -f "$tmp"
  else
    mv "$tmp" "$filtered"
  fi
}

report_fail() {
  local msg="$1" filtered="$2"
  echo "FAIL: $msg"
  head -40 "$filtered"
  local n
  n=$(wc -l <"$filtered" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
}

run_check() {
  local pat="$1" msg="$2" id="$3" drop_described="${4:-}"
  local hitfile="$TMPDIR_GATE/hit.$id"
  local filtered="$TMPDIR_GATE/filt.$id"
  local rcfile="$TMPDIR_GATE/rc.$id"
  scan "$pat" "$hitfile"
  filter_hits "$hitfile" "$filtered" "$drop_described"
  if [[ -s "$filtered" ]]; then
    report_fail "$msg" "$filtered"
    echo 1 >"$rcfile"
  else
    echo 0 >"$rcfile"
  fi
}

# Concurrent smell checks (wall-clock hot-path; each scan is independent)
pids=()
run_check '\bas\s+any\b' 'as any banned' asany &
pids+=($!)
run_check ':\s*any\b' 'explicit : any banned' colonany &
pids+=($!)
run_check '<any>' 'generic any banned' genany &
pids+=($!)
run_check '\bany\[' 'any[] banned' anyarr &
pids+=($!)
run_check '\bPromise\s*<\s*any\s*>' 'Promise<any> banned' promiseany &
pids+=($!)
run_check '\bRecord\s*<\s*[^,]+,\s*any\s*>' 'Record<*, any> banned' recordany &
pids+=($!)
run_check '@ts-ignore\b' '@ts-ignore banned (prefer typed fix or @ts-expect-error with description via oxlint)' tsignore &
pids+=($!)
run_check '@ts-nocheck\b' '@ts-nocheck banned' tsnocheck &
pids+=($!)
run_check '\bas\s+unknown\s+as\b' 'as unknown as banned (prefer named parse / satisfies; ts-rg-allow with rationale)' unknownas &
pids+=($!)
# Portable bare @ts-expect-error: match all, drop lines that already have a description
# (avoids PCRE2 lookahead; prior (?!...) silently no-oped under default rg)
run_check '@ts-expect-error\b' '@ts-expect-error requires a trailing description (e.g. // @ts-expect-error - reason)' tsexpect '@ts-expect-error\s+\S' &
pids+=($!)
run_check 'getElementById\s*\([^)]*\)\s*!' 'DOM non-null: getElementById(...)! banned; check null then use narrowed node' domid &
pids+=($!)
run_check 'querySelector(All)?\s*\([^)]*\)\s*!' 'DOM non-null: querySelector*(...)! banned; check null then use narrowed node' domqs &
pids+=($!)
run_check '\bJSON\.parse\s*\(' 'JSON.parse in src banned without a typed parse boundary (move behind a named parser or schema; ts-rg-allow on the parser line if needed)' jsonparse &
pids+=($!)
# Global fetch only — exclude method .fetch( (tRPC / React Query prefetch)
run_check '(^|[^.\w])fetch\s*\(' 'fetch in src banned without a named boundary (parse Response into a domain type; ts-rg-allow on the boundary line; method .fetch is allowed)' fetch &
pids+=($!)
run_check '\bnew\s+URL\s*\(' 'new URL in src banned without a named boundary (validate input; ts-rg-allow on the boundary line)' newurl &
pids+=($!)
# Accessor form avoids prose/docs; whole-object process.env to a schema parser is OK
run_check '\bprocess\.env(?:\.\w+|\[)' 'process.env in src banned without a named env parse boundary (ts-rg-allow on the parser line; whole-object process.env to a schema is OK)' processenv &
pids+=($!)

for pid in "${pids[@]}"; do
  wait "$pid" || true
done
shopt -s nullglob
for rcfile in "$TMPDIR_GATE"/rc.*; do
  if [[ "$(cat "$rcfile")" != "0" ]]; then
    fail=1
  fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
mode="product"
if [[ "$SKIP_DTS" -eq 1 ]]; then mode="library (TS_RG_SKIP_DTS=1)"; fi
echo "PASS ts-rg-gate ($ROOT/$SRC, $mode)"
