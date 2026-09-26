#!/usr/bin/env bash
# Tier 0: PSR Python smells (portable regex bar).
# PSR: PEP 8 / typing / runtime validation / trust boundaries.
# Usage: bash scripts/py-rg-gate.sh [root]
# Scan: PY_RG_SRC or src|lib|app|. Escape: py-rg-allow.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for py-rg-gate"
  exit 1
fi

pick_src() {
  if [[ -n "${PY_RG_SRC:-}" ]]; then echo "$PY_RG_SRC"; return; fi
  for candidate in src lib app; do
    [[ -d "$candidate" ]] && { echo "$candidate"; return; }
  done
  if compgen -G "*.py" >/dev/null; then
    echo "."
    return
  fi
  echo ""
}

SRC="$(pick_src)"
if [[ -z "$SRC" ]]; then
  echo "FAIL: expected source dir src (or lib/app) or *.py at root; set PY_RG_SRC (root=$ROOT)"
  exit 1
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

IDS=(bareexcept typeignore noqa mutabledef shelltrue ossystem evalcall execcall pickleload yamlload osenviron jsonloads)
PATS=(
  'except[[:space:]]*:'
  'type:[[:space:]]*ignore'
  '#[[:space:]]*noqa\b'
  'def[[:space:]]+[A-Za-z_][A-Za-z0-9_]*\([^)]*=[[:space:]]*[\[{]'
  'shell[[:space:]]*=[[:space:]]*True'
  '\bos\.system[[:space:]]*\('
  '(^|[^.\w])eval[[:space:]]*\('
  '(^|[^.\w])exec[[:space:]]*\('
  '\bpickle\.loads?[[:space:]]*\('
  '\byaml\.load[[:space:]]*\('
  '\bos\.environ[[:space:]]*\['
  '\bjson\.loads[[:space:]]*\('
)
# Keep lines that match DROP (described form); inverse of TS drop which removes good forms
DROPS=(
  ''
  'type:[[:space:]]*ignore[[:space:]]*\['
  '#[[:space:]]*noqa[[:space:]]*:'
  '' '' '' '' '' '' '' '' ''
)
MSGS=(
  'bare except: banned (catch specific exceptions; py-rg-allow with rationale)'
  'bare type: ignore banned (use type: ignore[code]; py-rg-allow with rationale)'
  'bare noqa banned (use noqa: CODE; py-rg-allow with rationale)'
  'mutable default argument banned (None + assign inside; py-rg-allow with rationale)'
  'subprocess shell=True banned (prefer argv list; py-rg-allow with rationale)'
  'os.system banned (prefer subprocess with argv list; py-rg-allow with rationale)'
  'eval( banned (prefer ast.literal_eval or typed parse; py-rg-allow with rationale)'
  'exec( banned (prefer importlib / explicit loaders; py-rg-allow with rationale)'
  'pickle.load* banned (untrusted data; prefer json/typed parse; py-rg-allow with rationale)'
  'yaml.load( banned (use safe_load; py-rg-allow with rationale)'
  'os.environ[ banned without named env parse boundary (templates/env_schema.py; py-rg-allow on parser line)'
  'json.loads in src banned without named parse boundary (templates/typed_parse.py; py-rg-allow on parser line)'
)

PAT_ARGS=()
for pat in "${PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=( --glob '*.py' --glob '!**/__pycache__/**' --glob '!**/.venv/**' --glob '!**/venv/**'
  --glob '!**/.git/**' --glob '!**/.ruff_cache/**' --glob '!**/site-packages/**'
  --glob '!**/.tox/**' --glob '!**/node_modules/**' )

if [[ "$SRC" != "." ]]; then
  rg_globs+=( --glob '!**/tests/**' --glob '!**/test_*.py' --glob '!**/*_test.py' )
fi

rg -n "${rg_globs[@]}" "${PAT_ARGS[@]}" "$SRC" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  rg -v 'py-rg-allow' "$ALL" >"$FILT" || true
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
    # Remove lines that already use the described form (type: ignore[code] / noqa: CODE)
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
echo "PASS py-rg-gate ($ROOT/$SRC, single-walk)"
