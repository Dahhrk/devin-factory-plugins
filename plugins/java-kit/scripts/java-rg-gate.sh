#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Java smells (portable regex bar).
# PSR: formatter; Checkstyle/Error Prone; nullability; SQL/string concat; System.out.
# Practical encode (language-farm): System.out/err, printStackTrace, SQL string concat,
# catch NullPointerException.
# Product formatter / Checkstyle / nullability tooling remain authoritative for depth;
# this gate is the portable rg bar for Java trust smells.
#
# Usage: bash scripts/java-rg-gate.sh [root] [path ...]
# Default scan: JAVA_RG_SRC or . Escape hatch: java-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for java-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${JAVA_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${JAVA_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
IDS=(system_out print_stack sql_concat npe_catch)
SCAN_PATS=(
  '\bSystem\.(out|err)\.print(ln|f)?[[:space:]]*\('
  '\.[[:space:]]*printStackTrace[[:space:]]*\('
  '"(SELECT|INSERT|UPDATE|DELETE|WITH)[[:space:]][^"]*"[[:space:]]*\+|\+[[:space:]]*"(SELECT|INSERT|UPDATE|DELETE|[[:space:]]+WHERE|[[:space:]]+FROM|[[:space:]]+AND|[[:space:]]+OR)[^"]*"'
  'catch[[:space:]]*\([[:space:]]*NullPointerException\b'
)
CLASS_PATS=(
  '\bSystem\.(out|err)\.print(ln|f)?[[:space:]]*\('
  '\.[[:space:]]*printStackTrace[[:space:]]*\('
  '"(SELECT|INSERT|UPDATE|DELETE|WITH)[[:space:]][^"]*"[[:space:]]*\+|\+[[:space:]]*"(SELECT|INSERT|UPDATE|DELETE|[[:space:]]+WHERE|[[:space:]]+FROM|[[:space:]]+AND|[[:space:]]+OR)[^"]*"'
  'catch[[:space:]]*\([[:space:]]*NullPointerException\b'
)
MSGS=(
  'System.out/err print banned (prefer logger; java-rg-allow with rationale)'
  'printStackTrace banned (prefer logger; java-rg-allow with rationale)'
  'SQL/string concat banned (prefer PreparedStatement / named params; java-rg-allow with rationale)'
  'catch NullPointerException banned (fix nullable contracts; java-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.java' --glob '!**/build/**' --glob '!**/.git/**' --glob '!**/out/**' --glob '!**/target/**' --glob '!**/test/**' --glob '!**/tests/**' --glob '!**/*Test.java' --glob '!**/*Tests.java' --glob '!**/generated/**' --glob '!**/vendor/**' )

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only / javadoc example hits (leading * or // after line num).
  rg -v 'java-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|/\*|\*)' >"$FILT" || true
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
  rg -- "$cpat" "$FILT" >"$hitfile" 2>/dev/null || true
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
echo "PASS java-rg-gate (${TARGETS[*]}, single-walk)"
