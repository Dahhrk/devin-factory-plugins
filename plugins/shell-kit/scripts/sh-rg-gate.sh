#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Shell smells (portable regex bar).
# PSR: quote expansions; explicit failure; safe temp files; avoid eval and
# pipe-to-shell. Product ShellCheck/shfmt remain authoritative for depth;
# this gate is the portable rg bar.
#
# Usage: bash scripts/sh-rg-gate.sh [root] [path ...]
# Default scan: SH_RG_SRC or . Escape hatch: sh-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for sh-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${SH_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${SH_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(evalcall unsafetmp forunquoted cdunquoted rmunquoted curlpipe)
SCAN_PATS=(
  '(^|[^[:alnum:]_])eval[[:space:]]'
  '/tmp/[^[:space:]"'"'"']*\$\$'
  'for[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+in[[:space:]]+\$[A-Za-z_{]'
  '^[[:space:]]*cd[[:space:]]+\$[A-Za-z_{]'
  'rm[[:space:]]+(-[a-zA-Z]*f[a-zA-Z]*|--recursive)[[:space:]]+\$[A-Za-z_{]'
  '(curl|wget)[^\n|]*\|[[:space:]]*(ba)?sh\b'
)
CLASS_PATS=(
  'eval[[:space:]]'
  '/tmp/[^[:space:]"'"'"']*\$\$'
  'for[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+in[[:space:]]+\$[A-Za-z_{]'
  ':[0-9]+:[[:space:]]*cd[[:space:]]+\$[A-Za-z_{]'
  'rm[[:space:]]+(-[a-zA-Z]*f[a-zA-Z]*|--recursive)[[:space:]]+\$[A-Za-z_{]'
  '(curl|wget)[^\n|]*\|[[:space:]]*(ba)?sh\b'
)
MSGS=(
  'eval banned (prefer argv arrays / functions; sh-rg-allow with rationale)'
  'unsafe /tmp/...$$ temp (use mktemp + trap; templates/safe_temp.sh; sh-rg-allow with rationale)'
  'unquoted for-in $var (quote expansions: for x in "$var" or array; sh-rg-allow with rationale)'
  'unquoted cd $var (quote: cd "$var"; sh-rg-allow with rationale)'
  'unquoted rm -f/$var (quote paths; prefer rm -f -- "$path"; sh-rg-allow with rationale)'
  'curl|sh / wget|bash pipe-to-shell banned (download, ShellCheck, then run; sh-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.sh' --glob '*.bash'
  --glob '!**/.git/**' --glob '!**/node_modules/**'
  --glob '!**/.venv/**' --glob '!**/vendor/**'
)

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allow-marked lines and comment-only hits (path:line:# ...)
  rg -v 'sh-rg-allow' "$ALL" | rg -v ':[0-9]+:[[:space:]]*#' >"$FILT" || true
else
  : >"$FILT"
fi

report_fail() {
  echo "FAIL: $1"
  head -40 "$2"
  local n
  n=$(wc -l <"$2" | tr -d ' ')
  if [[ "$n" -gt 40 ]]; then echo "... ($n total hits)"; fi
}

classify_one() {
  local i="$1"
  local id cpat hitfile rcfile
  id="${IDS[$i]}"
  cpat="${CLASS_PATS[$i]}"
  hitfile="$TMPDIR_GATE/hit.$id"
  rcfile="$TMPDIR_GATE/rc.$id"
  : >"$hitfile"
  rg -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
  if [[ -s "$hitfile" ]]; then echo 1 >"$rcfile"; else echo 0 >"$rcfile"; fi
}

if [[ -s "$FILT" ]]; then
  pids=()
  for i in "${!IDS[@]}"; do
    classify_one "$i" &
    pids+=($!)
  done
  for pid in "${pids[@]}"; do wait "$pid" || true; done
  for i in "${!IDS[@]}"; do
    if [[ "$(cat "$TMPDIR_GATE/rc.${IDS[$i]}")" != "0" ]]; then
      report_fail "${MSGS[$i]}" "$TMPDIR_GATE/hit.${IDS[$i]}"
      fail=1
    fi
  done
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS sh-rg-gate (${TARGETS[*]}, single-walk)"
