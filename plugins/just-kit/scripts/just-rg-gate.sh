#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Just smells (portable regex bar).
# PSR: no unchecked [script]/shebang recipes; no dotenv secrets in recipes;
# no export of secrets; no include of untrusted path; no curl|bash recipes.
# Language-farm. Product just --fmt / shellcheck remains authoritative; this gate
# is the portable rg bar for Just trust smells.
#
# Usage: bash scripts/just-rg-gate.sh [root] [path ...]
# Default scan: JUST_RG_SRC or . Escape hatch: just-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers justfile / Justfile / .justfile / *.just.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for just-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${JUST_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${JUST_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# unchecked_script_shebang: [script] attr or indented recipe shebang
# dotenv_secrets: set dotenv-*
# export_secrets: export SECRET-like / [env("SECRET"...)]
# include_untrusted: import/mod with {{, ~/, or absolute /
# curl_bash: curl|bash / wget|sh
IDS=(unchecked_script_shebang dotenv_secrets export_secrets include_untrusted curl_bash)
SCAN_PATS=(
  '(?m)^\[script\b|(?m)^[ \t]+#!/'
  '(?im)^set\s+dotenv-(?:load|path|filename|command|required|override)\b'
  '(?im)^export\s+[A-Z0-9_]*(?:SECRET|TOKEN|PASSWORD|PASSWD|API_KEY|PRIVATE_KEY|ACCESS_KEY|CREDENTIAL|AUTH_KEY)[A-Z0-9_]*\b|(?im)^\[env\(\s*["'\''][A-Z0-9_]*(?:SECRET|TOKEN|PASSWORD|PASSWD|API_KEY|PRIVATE_KEY|ACCESS_KEY|CREDENTIAL|AUTH_KEY)[A-Z0-9_]*'
  '(?im)^(?:import\??|mod\??\s+\S+)\s+[^\n]*\{\{|(?im)^(?:import\??|mod\??\s+\S+)\s+['\'']~/|(?im)^(?:import\??|mod\??\s+\S+)\s+['\'']/'
  '(?i)(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)
CLASS_PATS=(
  '(?m)^[^:]+:[0-9]+:\[script\b|(?m)^[^:]+:[0-9]+:[ \t]+#!/'
  '(?i):[0-9]+:\s*set\s+dotenv-(?:load|path|filename|command|required|override)\b'
  '(?i):[0-9]+:\s*export\s+[A-Z0-9_]*(?:SECRET|TOKEN|PASSWORD|PASSWD|API_KEY|PRIVATE_KEY|ACCESS_KEY|CREDENTIAL|AUTH_KEY)[A-Z0-9_]*\b|(?i):[0-9]+:\s*\[env\(\s*["'\''][A-Z0-9_]*(?:SECRET|TOKEN|PASSWORD|PASSWD|API_KEY|PRIVATE_KEY|ACCESS_KEY|CREDENTIAL|AUTH_KEY)[A-Z0-9_]*'
  '(?i):[0-9]+:\s*(?:import\??|mod\??\s+\S+)\s+[^\n]*\{\{|(?i):[0-9]+:\s*(?:import\??|mod\??\s+\S+)\s+['\'']~/|(?i):[0-9]+:\s*(?:import\??|mod\??\s+\S+)\s+['\'']/'
  '(?i):[0-9]+:.*(?:curl|wget)\s+[^\n|]*\|\s*(?:ba)?sh\b'
)

MSGS=(
  'unchecked [script]/shebang banned ([script] attribute or indented #!/ recipe shebang; prefer line recipes or just-rg-allow with rationale + set -euxo pipefail)'
  'dotenv secrets in recipes banned (set dotenv-load/path/filename/command/required/override; prefer CI/OIDC secrets; just-rg-allow with rationale)'
  'export of secrets banned (export SECRET|TOKEN|PASSWORD|API_KEY|... or [env("SECRET"...)]; prefer host/CI env; just-rg-allow with rationale)'
  'include of untrusted path banned (import/mod with {{ interpolation, ~/, or absolute / path; prefer static relative import '\''rules.just'\'' / mod foo; just-rg-allow with rationale)'
  'curl|bash banned (curl|bash / wget|sh pipe-to-shell recipe; prefer checksummed ./scripts/install.sh; just-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob 'justfile' --glob 'Justfile' --glob '.justfile'
  --glob '*.just'
  --glob '**/justfile' --glob '**/Justfile' --glob '**/.justfile'
  --glob '**/*.just'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure comment lines (# just comments).
  rg -v 'just-rg-allow' "$ALL" 2>/dev/null \
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
echo "PASS just-rg-gate (${TARGETS[*]}, single-walk)"
