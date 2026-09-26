#!/usr/bin/env bash
# Tier 0: Programming Standards Reference Assembly smells (portable regex bar).
# PSR: no shellcode in product paths; explicit section hygiene; no jmp-to-register
# without same-line comment gate.
# Language-farm. Product assemble/link remains authoritative for depth; this
# gate is the portable rg bar for Assembly trust smells.
#
# Usage: bash scripts/assembly-rg-gate.sh [root] [path ...]
# Default scan: ASSEMBLY_RG_SRC or . Escape hatch: assembly-rg-allow on the line.
# Hot-path: one tree walk (union of smells), classify hit set in parallel.
# Requires ripgrep (rg) with PCRE (-P).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
shift || true

if ! command -v rg >/dev/null 2>&1; then
  echo "FAIL: ripgrep (rg) required for assembly-rg-gate"
  exit 1
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
elif [[ -n "${ASSEMBLY_RG_SRC:-}" ]]; then
  # shellcheck disable=SC2206
  TARGETS=(${ASSEMBLY_RG_SRC})
else
  TARGETS=(.)
fi

fail=0
TMPDIR_GATE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_GATE"' EXIT
ALL="$TMPDIR_GATE/all"
FILT="$TMPDIR_GATE/filt"

# single-walk smell set (line-local)
IDS=(shellcode_label shellcode_payload nop_sled jmp_reg)
SCAN_PATS=(
  '(?i)\bshellcode\b'
  "(?i)\bdb\s+['\"]/bin/(sh|bash)['\"]"
  '(?i)\bdb\s+0x90\s*,\s*0x90\s*,\s*0x90'
  '(?i)^\s*jmp\s+(rax|rbx|rcx|rdx|rsi|rdi|rbp|rsp|r8|r9|r10|r11|r12|r13|r14|r15|eax|ebx|ecx|edx|esi|edi|ebp|esp)\b'
)
CLASS_PATS=(
  '(?i)\bshellcode\b'
  "(?i)\bdb\s+['\"]/bin/(sh|bash)['\"]"
  '(?i)\bdb\s+0x90\s*,\s*0x90\s*,\s*0x90'
  '(?i):[0-9]+:[[:space:]]*jmp\s+(rax|rbx|rcx|rdx|rsi|rdi|rbp|rsp|r8|r9|r10|r11|r12|r13|r14|r15|eax|ebx|ecx|edx|esi|edi|ebp|esp)\b'
)
MSGS=(
  'shellcode marker banned in product asm (prefer delete payload / move out of product paths; assembly-rg-allow with rationale)'
  'shellcode-style /bin/sh|/bin/bash db payload banned (prefer argv builders / documented tests outside product; assembly-rg-allow with rationale)'
  'nop-sled db 0x90,0x90,0x90+ banned (shellcode pattern; assembly-rg-allow with rationale)'
  'jmp to register without same-line ; comment banned (document why indirect; assembly-rg-allow with rationale)'
)

PAT_ARGS=()
for pat in "${SCAN_PATS[@]}"; do PAT_ARGS+=(-e "$pat"); done

rg_globs=(
  --glob '*.asm' --glob '*.s' --glob '*.S' --glob '*.nasm' --glob '*.inc'
  --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/vendor/**'
  --glob '!**/dist/**' --glob '!**/build/**' --glob '!**/_build/**'
  --glob '!**/target/**' --glob '!**/testdata/**' --glob '!**/bin/**'
  --glob '!**/cmake-build*/**'
)

rg -n -P "${rg_globs[@]}" "${PAT_ARGS[@]}" "${TARGETS[@]}" >"$ALL" 2>/dev/null || true
if [[ -s "$ALL" ]]; then
  # Drop allows. Keep comment-only lines for shellcode word hits in prose? Drop pure-comment shellcode mentions that are not labels.
  rg -v 'assembly-rg-allow' "$ALL" 2>/dev/null >"$FILT" || true
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

  # shellcode_label: keep path hits + label-like content; drop pure trailing-comment prose about the ban
  if [[ "$id" == "shellcode_label" && -s "$hitfile" ]]; then
    # Keep if path contains shellcode OR line looks like a label / identifier, not only a mid-comment essay.
    : >"$TMPDIR_GATE/hit.$id.keep"
    while IFS= read -r line || [[ -n "$line" ]]; do
      path="${line%%:*}"
      rest="${line#*:}"
      lineno="${rest%%:*}"
      text="${rest#*:}"
      if echo "$path" | rg -qi 'shellcode'; then
        echo "$line" >>"$TMPDIR_GATE/hit.$id.keep"
        continue
      fi
      if echo "$text" | rg -qi '^\s*\w*shellcode\w*\s*:'; then
        echo "$line" >>"$TMPDIR_GATE/hit.$id.keep"
        continue
      fi
      # bare identifier use (not only comment-only line)
      if echo "$text" | rg -qi '^\s*[^;]*\bshellcode\b'; then
        echo "$line" >>"$TMPDIR_GATE/hit.$id.keep"
      fi
    done <"$hitfile"
    mv "$TMPDIR_GATE/hit.$id.keep" "$hitfile"
  fi

  # jmp_reg: require same-line ; comment; drop hits whose source text contains ;
  if [[ "$id" == "jmp_reg" && -s "$hitfile" ]]; then
    : >"$TMPDIR_GATE/hit.$id.nc"
    while IFS= read -r line || [[ -n "$line" ]]; do
      rest="${line#*:}"
      src="${rest#*:}"
      if echo "$src" | rg -q ';'; then
        continue
      fi
      echo "$line" >>"$TMPDIR_GATE/hit.$id.nc"
    done <"$hitfile"
    mv "$TMPDIR_GATE/hit.$id.nc" "$hitfile"
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

# Path-level: any scanned path component named *shellcode*
PATH_HITS="$TMPDIR_GATE/path_shellcode"
: >"$PATH_HITS"
find "${TARGETS[@]}" \( -name '*.asm' -o -name '*.s' -o -name '*.S' -o -name '*.nasm' -o -name '*.inc' \) \
  -not -path '*/.git/*' -not -path '*/testdata/*' -not -path '*/bin/*' 2>/dev/null \
  | rg -i 'shellcode' >"$PATH_HITS" || true
if [[ -s "$PATH_HITS" ]]; then
  report_fail "shellcode path banned under product trees (rename / relocate; PSR: no shellcode in product paths)" "$PATH_HITS"
  fail=1
fi

# File-level section hygiene: instruction-bearing units need section .text or BITS+ORG.
MISSING="$TMPDIR_GATE/missing_section"
INSTR="$TMPDIR_GATE/instr"
HAS_TEXT="$TMPDIR_GATE/has_text"
HAS_BARE="$TMPDIR_GATE/has_bare"
: >"$MISSING"
rg -l -i -P "${rg_globs[@]}" '(?m)^\s*(mov|syscall|sysenter|int\s+|call|ret|jmp|push|pop|lea|xor|add|sub|cmp|test|nop)\b' "${TARGETS[@]}" >"$INSTR" 2>/dev/null || true
rg -l -i -P "${rg_globs[@]}" '(?i)(section|\.section)[[:space:]]+\.text|^\s*\.text\b' "${TARGETS[@]}" >"$HAS_TEXT" 2>/dev/null || true
rg -l -i -P "${rg_globs[@]}" '(?i)\bBITS\s+(16|32|64)\b' "${TARGETS[@]}" >"$TMPDIR_GATE/has_bits" 2>/dev/null || true
rg -l -i -P "${rg_globs[@]}" '(?i)\bORG\b' "${TARGETS[@]}" >"$TMPDIR_GATE/has_org" 2>/dev/null || true
# bare-metal = BITS and ORG both present
if [[ -s "$TMPDIR_GATE/has_bits" && -s "$TMPDIR_GATE/has_org" ]]; then
  sort -u "$TMPDIR_GATE/has_bits" >"$TMPDIR_GATE/bits.u"
  sort -u "$TMPDIR_GATE/has_org" >"$TMPDIR_GATE/org.u"
  comm -12 "$TMPDIR_GATE/bits.u" "$TMPDIR_GATE/org.u" >"$HAS_BARE" || true
else
  : >"$HAS_BARE"
fi
if [[ -s "$INSTR" ]]; then
  sort -u "$INSTR" >"$TMPDIR_GATE/instr.u"
  sort -u "$HAS_TEXT" >"$TMPDIR_GATE/has_text.u"
  sort -u "$HAS_BARE" >"$TMPDIR_GATE/has_bare.u"
  cat "$TMPDIR_GATE/has_text.u" "$TMPDIR_GATE/has_bare.u" | sort -u >"$TMPDIR_GATE/ok_section"
  comm -23 "$TMPDIR_GATE/instr.u" "$TMPDIR_GATE/ok_section" >"$MISSING" || true
fi
if [[ -s "$MISSING" ]]; then
  report_fail "instruction-bearing asm missing section .text / .text (or BITS+ORG bare-metal); prefer section .text; assembly-rg-allow not applicable file-wide — add the directive" "$MISSING"
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "PASS assembly-rg-gate (${TARGETS[*]}, single-walk)"
