#!/usr/bin/env bash
# Prove assembly-kit gates discriminate fixtures (pack maturity).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT
fail=0

probe() {
  local id="$1"; shift
  if "$@" >"$WORKDIR/$id.out" 2>&1; then echo 0 >"$WORKDIR/$id.rc"; else echo 1 >"$WORKDIR/$id.rc"; fi
}

require_grep() {
  local file="$1" pat="$2" label="$3"
  if [[ ! -f "$file" ]] || ! grep -q -E -e "$pat" -- "$file"; then
    echo "FAIL selfcheck: $label"; fail=1
  else
    echo "ok: $label"
  fi
}

probe bad-rg bash "$HERE/assembly-rg-gate.sh" "$ROOT/testdata/bad" . &
probe good-rg bash "$HERE/assembly-rg-gate.sh" "$ROOT/testdata/good" . &
probe good-hot bash "$HERE/assembly-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe tight-hot env ASSEMBLY_RG_BUDGET_MS=1 bash "$HERE/assembly-hotpath-gate.sh" "$ROOT/testdata/good" . &
probe good-build env ASSEMBLY_BUILD_CONFIG_ONLY=1 bash "$HERE/assembly-build-gate.sh" "$ROOT/testdata/good" &
probe build-missing env ASSEMBLY_BUILD_CONFIG_ONLY=1 bash "$HERE/assembly-build-gate.sh" "$ROOT/testdata/build-missing" &
probe build-weak env ASSEMBLY_BUILD_CONFIG_ONLY=1 bash "$HERE/assembly-build-gate.sh" "$ROOT/testdata/build-weak" &
wait

check_fail() {
  local id="$1" label="$2"
  if [[ "$(cat "$WORKDIR/$id.rc")" -eq 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}
check_pass() {
  local id="$1" label="$2"
  if [[ "$(cat "$WORKDIR/$id.rc")" -ne 0 ]]; then
    echo "FAIL selfcheck: expected $label"; cat "$WORKDIR/$id.out"; fail=1
  else
    echo "ok: $label"
  fi
}

check_fail bad-rg "rg fails on bad"
check_pass good-rg "rg passes on good"
check_pass good-hot "hotpath budget passes on good"
check_fail tight-hot "hotpath budget fails when ASSEMBLY_RG_BUDGET_MS=1"
check_pass good-build "build passes on good (config)"
check_fail build-missing "build fails without wiring"
check_fail build-weak "build fails when Makefile lacks nasm/gas/as"

require_grep "$HERE/assembly-rg-gate.sh" 'single-walk' "rg gate encodes single-walk hot-path"
require_grep "$HERE/assembly-hotpath-gate.sh" 'ASSEMBLY_RG_BUDGET_MS' "hotpath gate encodes budget"
require_grep "$HERE/assembly-hotpath-gate.sh" '250' "hotpath gate default budget 250ms"
require_grep "$ROOT/testdata/bad/smell.asm" 'shellcode' "bad fixture encodes shellcode label"
require_grep "$ROOT/testdata/bad/smell.asm" '/bin/sh' "bad fixture encodes /bin/sh payload"
require_grep "$ROOT/testdata/bad/smell.asm" '0x90, 0x90, 0x90' "bad fixture encodes nop sled"
require_grep "$ROOT/testdata/bad/smell.asm" 'jmp rax' "bad fixture encodes jmp-reg without comment"
require_grep "$ROOT/testdata/good/ok.asm" 'assembly-rg-allow' "good fixture encodes allow marker"
require_grep "$ROOT/testdata/good/Makefile" 'nasm' "good Makefile encodes nasm"
require_grep "$ROOT/templates/no_shellcode.asm" 'section \.text' "no_shellcode template encodes section .text"
require_grep "$ROOT/templates/section_hygiene.asm" 'section \.text' "section_hygiene template encodes section .text"
require_grep "$ROOT/templates/jmp_reg_comment.asm" 'jmp rax' "jmp_reg_comment template encodes commented jmp"

for f in no_shellcode.asm section_hygiene.asm jmp_reg_comment.asm github-workflows/assembly-gates.yml; do
  if [[ ! -f "$ROOT/templates/$f" ]]; then
    echo "FAIL selfcheck: missing templates/$f"; fail=1
  else echo "ok: template $f present"; fi
done

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS assembly-kit-selfcheck"
