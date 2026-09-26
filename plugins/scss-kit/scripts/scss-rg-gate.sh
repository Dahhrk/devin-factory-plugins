#!/usr/bin/env bash
# Tier 0: Programming Standards Reference SCSS/Sass smells (portable regex bar).
# PSR: dart-sass/sass compile wiring; no !important abuse; no @extend overuse;
# no /deep/ or >>>; nesting depth ≤4 when gateable.
# Language-farm. Product sass remains authoritative for compile; this gate is
# the portable rg + nesting bar for SCSS/Sass trust smells.
#
# Usage: bash scripts/scss-rg-gate.sh [root] [path ...]
# Default scan: SCSS_RG_SRC or . Escape hatch: scss-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel,
# then file-level nesting-depth >4.
# Requires ripgrep (rg) with PCRE (-P). Covers *.scss and *.sass.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for scss-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${SCSS_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${SCSS_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-level)
IDS=(important_abuse extend_overuse deep_combinator)
SCAN_PATS=(
  '(?i)!important\b'
  '(?i)@extend\b'
  '(?i)(/deep/|>>>)'
)
CLASS_PATS=(
  '(?i)!important\b'
  '(?i)@extend\b'
  '(?i)(/deep/|>>>)'
)
MSGS=(
  '!important abuse banned (prefer specificity / @layer / mixin; scss-rg-allow with rationale)'
  '@extend overuse banned (prefer mixins / placeholder composition without extend graph; scss-rg-allow with rationale; dart-sass extend is complex)'
  '/deep/ or >>> deep combinator banned (prefer :deep() / native nesting / BEM; scss-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.scss' --glob '*.sass' --glob '*.SCSS' --glob '*.SASS' --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**' --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**' --glob '!**/testdata/**' )

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and comment-only hits (line is only a // or /* comment).
  rg -v 'scss-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(//|/\*)' >"$FILT" || true
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

# File-level: nesting depth >4 (.scss brace depth; .sass indent depth).
NEST_HIT="$TMPDIR_GATE/hit.nesting_depth"
: >"$NEST_HIT"
MAX_NEST="${SCSS_MAX_NESTING:-4}"

check_scss_brace_depth() {
  local f="$1"
  # Skip if every smell line in file is allow-marked? File-level: still check unless whole-file allow via env.
  python3 - "$f" "$MAX_NEST" <<'PY' >>"$NEST_HIT" 2>/dev/null || true
import sys
path, limit = sys.argv[1], int(sys.argv[2])
try:
    text = open(path, encoding="utf-8", errors="replace").read()
except OSError:
    sys.exit(0)
depth = 0
max_d = 0
i = 0
n = len(text)
in_s = in_d = in_lc = in_bc = False
while i < n:
    ch = text[i]
    nxt = text[i+1] if i+1 < n else ""
    if in_lc:
        if ch == "\n":
            in_lc = False
        i += 1
        continue
    if in_bc:
        if ch == "*" and nxt == "/":
            in_bc = False
            i += 2
            continue
        i += 1
        continue
    if in_s:
        if ch == "\\":
            i += 2
            continue
        if ch == "'":
            in_s = False
        i += 1
        continue
    if in_d:
        if ch == "\\":
            i += 2
            continue
        if ch == '"':
            in_d = False
        i += 1
        continue
    if ch == "/" and nxt == "/":
        in_lc = True
        i += 2
        continue
    if ch == "/" and nxt == "*":
        in_bc = True
        i += 2
        continue
    if ch == "'":
        in_s = True
        i += 1
        continue
    if ch == '"':
        in_d = True
        i += 1
        continue
    if ch == "{":
        depth += 1
        if depth > max_d:
            max_d = depth
        i += 1
        continue
    if ch == "}":
        depth = max(0, depth - 1)
        i += 1
        continue
    i += 1
if max_d > limit:
    print(f"{path}:1: nesting depth {max_d} exceeds max {limit}")
PY
}

check_sass_indent_depth() {
  local f="$1"
  python3 - "$f" "$MAX_NEST" <<'PY' >>"$NEST_HIT" 2>/dev/null || true
import sys
path, limit = sys.argv[1], int(sys.argv[2])
try:
    lines = open(path, encoding="utf-8", errors="replace").read().splitlines()
except OSError:
    sys.exit(0)
max_d = 0
for lineno, line in enumerate(lines, 1):
    if not line.strip():
        continue
    if line.lstrip().startswith("//") or line.lstrip().startswith("/*"):
        continue
    # count leading spaces (tabs count as 2)
    expanded = line.replace("\t", "  ")
    lead = len(expanded) - len(expanded.lstrip(" "))
    # assume 2-space indent
    depth = lead // 2
    if depth > max_d:
        max_d = depth
    if depth > limit:
        print(f"{path}:{lineno}: nesting depth {depth} exceeds max {limit}")
        break
PY
}

# Collect scss/sass files under TARGETS
mapfile -t nest_files < <(
  for t in "${TARGETS[@]}"; do
    if [[ -f "$t" ]]; then
      case "$t" in
        *.scss|*.sass|*.SCSS|*.SASS) printf '%s\n' "$t" ;;
      esac
    else
      find "$t" \( -name '*.scss' -o -name '*.sass' -o -name '*.SCSS' -o -name '*.SASS' \) \
        -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
        -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/_build/*' \
        -not -path '*/target/*' -not -path '*/testdata/*' 2>/dev/null || true
    fi
  done | sort -u
)

for f in "${nest_files[@]:-}"; do
  [[ -z "$f" ]] && continue
  # Skip files where nesting allow is present on a dedicated marker line
  if rg -q 'scss-rg-allow.*nest' "$f" 2>/dev/null; then
    continue
  fi
  case "$f" in
    *.sass|*.SASS) check_sass_indent_depth "$f" ;;
    *) check_scss_brace_depth "$f" ;;
  esac
done

if [[ -s "$NEST_HIT" ]]; then
  report_fail "nesting depth >${MAX_NEST} banned (prefer flatter selectors / mixins / BEM; scss-rg-allow nest rationale on a line in file; SCSS_MAX_NESTING override)" "$NEST_HIT"
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS scss-rg-gate (${TARGETS[*]}, single-walk)"
