#!/usr/bin/env bash
# Tier 0: Programming Standards Reference R smells (portable regex bar).
# PSR: lintr lint; no attach(); TRUE/FALSE not T/F; no eval(parse()).
# Language-farm. Product lintr remains authoritative for depth; this
# gate is the portable rg bar for R trust smells.
#
# Usage: bash scripts/r-rg-gate.sh [root] [path ...]
# Default scan: R_RG_SRC or . Escape hatch: r-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for r-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${R_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${R_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(attach t_f_symbol eval_parse)
SCAN_PATS=(
  '\battach\s*\('
  '(?<![A-Za-z0-9_.$])\b[TF]\b(?![A-Za-z0-9_.$])'
  '\beval\s*\(\s*parse\s*\('
)
CLASS_PATS=(
  '\battach\s*\('
  '(?<![A-Za-z0-9_.$])\b[TF]\b(?![A-Za-z0-9_.$])'
  '\beval\s*\(\s*parse\s*\('
)
MSGS=(
  'attach() banned (prefer pkg::fun / @importFrom / explicit env; r-rg-allow with rationale; lintr undesirable_function_linter)'
  'Symbol T/F banned (prefer TRUE/FALSE; r-rg-allow with rationale; lintr T_and_F_symbol_linter)'
  'eval(parse()) banned (prefer get / [[ / explicit map / rlang; r-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.R' --glob '*.r' --glob '*.Rmd' --glob '*.rmd' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/renv/**' --glob '!**/packrat/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (# ...).
  rg -v 'r-rg-allow' "$ALL" 2>/dev/null \
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
  # Drop T/F hits that are clearly inside quotes (simple heuristic).
  if [[ "$id" == "t_f_symbol" && -s "$hitfile" ]]; then
    rg -v ':[0-9]+:.*["'\''][^"'\'']*\b[TF]\b' "$hitfile" >"$TMPDIR_GATE/hit.$id.nq" 2>/dev/null || true
    # Keep only lines where T/F appears outside a quoted segment roughly:
    # prefer lines matching assignment/arg forms.
    rg -P '(<-|=|\(|,|\breturn\s*\()\s*[TF]\b|\b[TF]\s*(,|\)|;|$)' "$hitfile" >"$TMPDIR_GATE/hit.$id.tf" 2>/dev/null || true
    if [[ -s "$TMPDIR_GATE/hit.$id.tf" ]]; then
      mv "$TMPDIR_GATE/hit.$id.tf" "$hitfile"
    else
      : >"$hitfile"
    fi
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
echo "PASS r-rg-gate (${TARGETS[*]}, single-walk)"
