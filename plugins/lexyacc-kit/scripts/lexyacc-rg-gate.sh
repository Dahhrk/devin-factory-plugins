#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Lex/Yacc smells (portable regex bar).
# PSR: no untrusted %include/#include paths; no yyerror silence; no unbounded
# yytext buffers; no generated C without bounds-checked yytext pointers.
# Language-farm. Product flex/bison CI remains authoritative; this gate is the
# portable rg bar for Lex/Yacc trust smells.
#
# Usage: bash scripts/lexyacc-rg-gate.sh [root] [path ...]
# Default scan: LEXYACC_RG_SRC or . Escape hatch: lexyacc-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.l *.y *.lex *.yacc *.ll *.yy.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for lexyacc-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${LEXYACC_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${LEXYACC_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# include_untrusted: %include absolute/URL/$VAR or #include absolute/../ /$VAR
# yyerror_silence: empty/discard yyerror body
# unbounded_yytext: strcpy/sprintf/strcat of yytext
# unbounded_yytext_ptr: pointer walk on yytext without yyleng on same line
IDS=(include_untrusted yyerror_silence unbounded_yytext unbounded_yytext_ptr)
SCAN_PATS=(
  '(?i)(?:%include\s+["'\'']?(?:/|[A-Za-z]:\\|\\\\|https?:|\$\{|\$[A-Za-z_])|#include\s*[<"](?:/|[.]{2}/|\$\{|\$[A-Za-z_]))'
  '(?i)\b(?:void\s+)?yyerror\s*\([^)]*\)\s*\{(?:\s*(?:return\s*;|(?:\(void\))?\s*\w+\s*;)*\s*)\}'
  '(?i)\b(?:strcpy|strcat)\s*\(\s*[^,]+,\s*yytext\s*\)|\bsprintf\s*\(\s*[^,]+,\s*[^,]*,\s*yytext\s*\)'
  '(?i)(?:char\s*\*\s*\w+\s*=\s*yytext\b|while\s*\(\s*\*+\s*yytext\b|for\s*\([^;]*\b(?:char\s*\*\s*)?\w+\s*=\s*yytext\b)'
)
CLASS_PATS=(
  '(?i):[0-9]+:.*(?:%include\s+["'\'']?(?:/|[A-Za-z]:\\|\\\\|https?:|\$\{|\$[A-Za-z_])|#include\s*[<"](?:/|[.]{2}/|\$\{|\$[A-Za-z_]))'
  '(?i):[0-9]+:.*\b(?:void\s+)?yyerror\s*\([^)]*\)\s*\{(?:\s*(?:return\s*;|(?:\(void\))?\s*\w+\s*;)*\s*)\}'
  '(?i):[0-9]+:.*(?:\b(?:strcpy|strcat)\s*\(\s*[^,]+,\s*yytext\s*\)|\bsprintf\s*\(\s*[^,]+,\s*[^,]*,\s*yytext\s*\))'
  '(?i):[0-9]+:.*(?:char\s*\*\s*\w+\s*=\s*yytext\b|while\s*\(\s*\*+\s*yytext\b|for\s*\([^;]*\b(?:char\s*\*\s*)?\w+\s*=\s*yytext\b)'
)

MSGS=(
  'untrusted %include/#include path banned (%include absolute/URL/$VAR or #include absolute/../ /$VAR; prefer static relative include; lexyacc-rg-allow with rationale)'
  'yyerror silence banned (empty or discard-only yyerror body; prefer fprintf(stderr, "%s\\n", msg); lexyacc-rg-allow with rationale)'
  'unbounded yytext buffer banned (strcpy/sprintf/strcat of yytext; prefer snprintf/strncpy with yyleng; lexyacc-rg-allow with rationale)'
  'unbounded yytext pointer walk banned (char *p = yytext / while (*yytext) / for (... = yytext) without yyleng bound on same line; prefer index < yyleng; lexyacc-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.l' --glob '*.y' --glob '*.lex' --glob '*.yacc' --glob '*.ll' --glob '*.yy'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure // or /* comment-only lines (C-style in actions).
  rg -v 'lexyacc-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(?://|/\*)' >"$FILT" || true
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
echo "PASS lexyacc-rg-gate (${TARGETS[*]}, single-walk)"
