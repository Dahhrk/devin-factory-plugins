#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Batchfile smells (portable regex bar).
# PSR: no unquoted %VAR% expansion; no delayedExpansion footguns; no call of
# untrusted paths; no curl|powershell download-exec; no secrets in set.
# Language-farm. Product cmd /c / BatchScript CI remains authoritative; this
# gate is the portable rg bar for Batchfile trust smells.
#
# Usage: bash scripts/bat-rg-gate.sh [root] [path ...]
# Default scan: BAT_RG_SRC or . Escape hatch: bat-rg-allow on the line.
# Hot-path: one tree walk (union of line smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P). Covers *.bat / *.cmd.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for bat-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${BAT_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${BAT_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set
# unquoted_var: unquoted %VAR% in path/command contexts
# delayed_expansion: EnableDelayedExpansion + call/start/cmd !var! footguns
# call_untrusted: call %VAR% / absolute drive / UNC / URL
# curl_powershell: curl|powershell / iex DownloadString / irm pipe-exec
# secrets_in_set: set PASSWORD=/SECRET=/TOKEN=/API_KEY=…
IDS=(unquoted_var delayed_expansion call_untrusted curl_powershell secrets_in_set)
SCAN_PATS=(
  '(?i)(?:\b(?:cd|chdir|call|start)\s+%[A-Za-z_][\w]*%|\bif\s+exist\s+%[A-Za-z_][\w]*%|\b(?:copy|xcopy|move|del|erase|type|ren|rename)\s+%[A-Za-z_][\w]*)'
  '(?i)(?:setlocal\s+[^\n]*EnableDelayedExpansion|(?:call|start|cmd\s+/c)\s+[^\n]*![A-Za-z_][\w]*!)'
  '(?i)\bcall\s+(?:%[A-Za-z_][\w]*%|"%[A-Za-z_][\w]*%"|[A-Za-z]:\\{1,2}|\\\\|https?:)'
  '(?i)(?:curl|wget)\s+[^\n|]*\|\s*powershell\b|(?i)powershell[^\n]*(?:-c|-Command|-EncodedCommand)[^\n]*(?:iex\b|Invoke-Expression|DownloadString|irm\b|Invoke-RestMethod)|(?i)powershell[^\n]*DownloadString'
  '(?i)\bset\s+(?:\/[ap]\s+)?(?:"?)(?:SECRET|PASSWORD|TOKEN|API_?KEY|APIKEY|PRIVATE_?KEY|ACCESS_?KEY|AUTH)[_A-Za-z0-9]*\s*='
)
CLASS_PATS=(
  '(?i):[0-9]+:.*(?:\b(?:cd|chdir|call|start)\s+%[A-Za-z_][\w]*%|\bif\s+exist\s+%[A-Za-z_][\w]*%|\b(?:copy|xcopy|move|del|erase|type|ren|rename)\s+%[A-Za-z_][\w]*)'
  '(?i):[0-9]+:.*(?:setlocal\s+[^\n]*EnableDelayedExpansion|(?:call|start|cmd\s+/c)\s+[^\n]*![A-Za-z_][\w]*!)'
  '(?i):[0-9]+:.*\bcall\s+(?:%[A-Za-z_][\w]*%|"%[A-Za-z_][\w]*%"|[A-Za-z]:\\{1,2}|\\\\|https?:)'
  '(?i):[0-9]+:.*(?:(?:curl|wget)\s+[^\n|]*\|\s*powershell\b|powershell[^\n]*(?:-c|-Command|-EncodedCommand)[^\n]*(?:iex\b|Invoke-Expression|DownloadString|irm\b|Invoke-RestMethod)|powershell[^\n]*DownloadString)'
  '(?i):[0-9]+:.*\bset\s+(?:\/[ap]\s+)?(?:"?)(?:SECRET|PASSWORD|TOKEN|API_?KEY|APIKEY|PRIVATE_?KEY|ACCESS_?KEY|AUTH)[_A-Za-z0-9]*\s*='
)

MSGS=(
  'unquoted %VAR% expansion banned (cd/call/start/if exist/copy/… with unquoted %VAR%; prefer "%VAR%" / "%~1"; bat-rg-allow with rationale)'
  'delayedExpansion footgun banned (EnableDelayedExpansion or call/start/cmd /c !var!; prefer quoted %VAR% / careful blocks; bat-rg-allow with rationale)'
  'call of untrusted path banned (call %VAR% / call "C:\\…" / UNC / URL; prefer call :label or static relative helper.bat; bat-rg-allow with rationale)'
  'curl|powershell download-exec banned (curl|powershell / iex DownloadString / irm pipe-exec; prefer checksummed local script; bat-rg-allow with rationale)'
  'secrets in set banned (set PASSWORD=/SECRET=/TOKEN=/API_KEY=…; prefer secret store / CI env injection; bat-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.bat' --glob '*.cmd'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**' --glob '!**/target/**'
  --glob '!**/testdata/**' --glob '!**/examples/**' --glob '!**/e2e/**' --glob '!**/fixtures/**'
  --glob '!**/.venv/**' --glob '!**/venv/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows and pure REM/:: comment lines.
  rg -v 'bat-rg-allow' "$ALL" 2>/dev/null \
    | rg -v '^[^\n]*:[0-9]+:[[:space:]]*(?:REM\b|::|@?rem\b)' >"$FILT" || true
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
echo "PASS bat-rg-gate (${TARGETS[*]}, single-walk)"
