#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Makefile smells (portable regex bar).
# PSR: no recursive make without .PHONY; no tab/space mix; no unchecked $(shell);
# no include of untrusted path; no .ONESHELL abuse / curl|bash recipes.
# Language-farm. Product checkmake / remake remains authoritative; this gate is
# the portable rg bar for Makefile trust smells.
#
# Usage: bash scripts/makefile-rg-gate.sh [root] [path ...]
# Default scan: MAKEFILE_RG_SRC or . Escape hatch: makefile-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers Makefile / makefile / GNUmakefile / *.mk / *.make.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for makefile-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${MAKEFILE_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${MAKEFILE_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# recursive_make: recipe lines with $(MAKE)/${MAKE}; post-filter files lacking .PHONY
# tab_space: space-indented recipe-like commands
# unchecked_shell: $(shell ...)
# include_untrusted: include/(-)include with $(var) not in allowlist
# oneshell_curl_bash: .ONESHELL or curl|bash / wget|sh
IDS=(recursive_make_no_phony tab_space_mix unchecked_shell include_untrusted oneshell_curl_bash)
SCAN_PATS=(
  '(?m)^\t.*\$[\(\{]MAKE[\)\}]'
  '(?m)^ +(?:[-@+]*)?(?:cp |rm |mv |echo |curl |wget |mkdir |chmod |cat |install |printf |\$[\(\{]|python|npm |node |cargo |go |docker |cmake |make |bash |sh |apt |yum |apk )'
  '\$\(shell\b'
  '(?im)^\s*-?include\s+\S*\$[\(\{](?!(?:CURDIR|srcdir|SRCDIR|MAKEFILE_LIST)\b)'
  '(?m)^\.ONESHELL\b|(?i)(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)
CLASS_PATS=(
  '(?m)^[^:]+:[0-9]+:\t.*\$[\(\{]MAKE[\)\}]'
  '(?m)^[^:]+:[0-9]+: +(?:[-@+]*)?(?:cp |rm |mv |echo |curl |wget |mkdir |chmod |cat |install |printf |\$[\(\{]|python|npm |node |cargo |go |docker |cmake |make |bash |sh |apt |yum |apk )'
  ':[0-9]+:.*\$\(shell\b'
  '(?i):[0-9]+:\s*-?include\s+\S*\$[\(\{](?!(?:CURDIR|srcdir|SRCDIR|MAKEFILE_LIST)\b)'
  '(?m)^[^:]+:[0-9]+:\.ONESHELL\b|(?i):[0-9]+:.*(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)

MSGS=(
  'recursive make without .PHONY banned ($(MAKE)/${MAKE} in recipe and file lacks .PHONY; declare .PHONY for recursive/action targets; makefile-rg-allow with rationale)'
  'tab/space mix banned (space-indented recipe; recipe lines must start with a real tab; makefile-rg-allow with rationale)'
  'unchecked $(shell) banned ($(shell ...) without makefile-rg-allow; prefer make natives or check .SHELLSTATUS; makefile-rg-allow with rationale)'
  'include of untrusted path banned (include/(-)include $(...) variable / untrusted path; prefer static include rules.mk or vetted CURDIR/srcdir/SRCDIR/MAKEFILE_LIST; makefile-rg-allow with rationale)'
  '.ONESHELL / curl|bash banned (.ONESHELL or curl|bash / wget|sh pipe-to-shell recipe; prefer tabbed multi-line recipes + checksum install; makefile-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob 'Makefile' --glob 'makefile' --glob 'GNUmakefile'
  --glob '*.mk' --glob '*.make'
  --glob '**/Makefile' --glob '**/makefile' --glob '**/GNUmakefile'
  --glob '**/*.mk' --glob '**/*.make'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure comment lines (# make comments).
  rg -v 'makefile-rg-allow' "$ALL" 2>/dev/null \
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

# For recursive_make_no_phony: keep hits only when the source file lacks .PHONY
filter_recursive_no_phony() {
  local infile="$1" outfile="$2"
  : >"$outfile"
  [[ -s "$infile" ]] || return 0
  local line file
  while IFS= read -r line || [[ -n "$line" ]]; do
    file="${line%%:*}"
    if [[ -f "$file" ]]; then
      if ! rg -q -e '^\.PHONY\b' -- "$file" 2>/dev/null; then
        printf '%s\n' "$line" >>"$outfile"
      fi
    else
      printf '%s\n' "$line" >>"$outfile"
    fi
  done <"$infile"
}

classify_one() {
  local i="$1" id="${IDS[$i]}" cpat="${CLASS_PATS[$i]}"
  local hitfile="$TMPDIR_GATE/hit.$id" rcfile="$TMPDIR_GATE/rc.$id" raw="$TMPDIR_GATE/raw.$id"
  : >"$hitfile"
  rg -P -- "$cpat" "$FILT" >"$raw" 2>/dev/null || true
  if [[ "$id" == "recursive_make_no_phony" ]]; then
    filter_recursive_no_phony "$raw" "$hitfile"
  else
    cat "$raw" >"$hitfile"
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
echo "PASS makefile-rg-gate (${TARGETS[*]}, single-walk)"
