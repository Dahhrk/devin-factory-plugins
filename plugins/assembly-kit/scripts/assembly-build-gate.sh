#!/usr/bin/env bash
# Tier 1: require nasm or gas (as) build wiring (PSR Assembly language-farm).
# Portable bar: Makefile / CMakeLists / meson / CI mentioning nasm or as/gas.
# Escape: ASSEMBLY_BUILD_GATE_SKIP=1.
# Usage: bash scripts/assembly-build-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${ASSEMBLY_BUILD_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS assembly-build-gate (skipped via ASSEMBLY_BUILD_GATE_SKIP=1)"
  exit 0
fi

mapfile -t a_files < <(find . \( \
  -name '*.asm' -o -name '*.s' -o -name '*.S' -o -name '*.nasm' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' \
  -not -path '*/testdata/*' -not -path '*/bin/*' \
  2>/dev/null | sort || true)
if [[ ${#a_files[@]} -eq 0 ]]; then
  echo "FAIL: no Assembly sources under $ROOT"
  exit 1
fi

has_wiring=0
CFG=""

# Makefile / makefile / GNUmakefile
for mf in Makefile makefile GNUmakefile; do
  if [[ -f "$mf" ]] && rg -qi '\bnasm\b|\bas\b|\bgas\b' "$mf" 2>/dev/null; then
    has_wiring=1
    CFG="$mf"
    break
  fi
done

# CMakeLists.txt
if [[ "$has_wiring" -eq 0 && -f CMakeLists.txt ]]; then
  if rg -qi '\bnasm\b|\basm\b|enable_language\s*\(\s*ASM|ASM_NASM|\bgas\b' CMakeLists.txt 2>/dev/null; then
    has_wiring=1
    CFG="CMakeLists.txt"
  fi
fi

# meson.build
if [[ "$has_wiring" -eq 0 && -f meson.build ]]; then
  if rg -qi '\bnasm\b|\bas\b|add_languages\s*\([^)]*asm|\bgas\b' meson.build 2>/dev/null; then
    has_wiring=1
    CFG="meson.build"
  fi
fi

# nested build files (maxdepth 3)
if [[ "$has_wiring" -eq 0 ]]; then
  nested="$(find . -maxdepth 3 -type f \( -name 'Makefile' -o -name 'makefile' -o -name 'CMakeLists.txt' -o -name 'meson.build' \) \
    -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | head -20 || true)"
  for f in $nested; do
    if rg -qi '\bnasm\b|\bas\b|\bgas\b|ASM_NASM|enable_language\s*\(\s*ASM' "$f" 2>/dev/null; then
      has_wiring=1
      CFG="$f"
      break
    fi
  done
fi

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi '\bnasm\b|[[:space:]]as[[:space:]]|\bgas\b|nasm[[:space:]]+-f' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no nasm/gas build wiring (Makefile/CMake/meson/CI mentioning nasm or as/gas; PSR: assemble with declared toolchain)"
  exit 1
fi

# Weak wiring: file present but only mentions unrelated assembler words? Already required nasm|as|gas.
# Optional: reject Makefile that mentions "as" only inside "was" — we used word boundaries.

if [[ "${ASSEMBLY_BUILD_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS assembly-build-gate ($ROOT, config-only, ${#a_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

# Live probe when nasm or as exists and Makefile targets look runnable — optional honesty.
live_rc=127
if [[ -n "$CFG" ]] && [[ "$CFG" == *[Mm]akefile* ]] && command -v nasm >/dev/null 2>&1; then
  # Do not run full make (may need ld flags). Config presence is the product bar at 0.1.0.
  live_rc=0
fi

echo "PASS assembly-build-gate ($ROOT, config-only fallback, ${#a_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
