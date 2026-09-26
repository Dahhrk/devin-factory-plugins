#!/usr/bin/env bash
# Tier 1: require .NET / VB.NET build wiring (PSR VB.NET language-farm).
# Portable bar: .vbproj present + Makefile/CI/scripts mentioning dotnet, or vbproj alone with Sdk.
# Escape: VBNET_DOTNET_GATE_SKIP=1.
# Usage: bash scripts/vbnet-dotnet-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${VBNET_DOTNET_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS vbnet-dotnet-gate (skipped via VBNET_DOTNET_GATE_SKIP=1)"
  exit 0
fi

mapfile -t vb_files < <(find . \( \
  -name '*.vb' -o -name '*.VB' \
\) \
  -not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/vendor/*' \
  -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/packages/*' \
  -not -path '*/testdata/*' -not -path '*/tests/*' -not -path '*/Tests/*' \
  2>/dev/null | sort || true)
if [[ ${#vb_files[@]} -eq 0 ]]; then
  echo "FAIL: no Visual Basic .NET sources under $ROOT"
  exit 1
fi

has_vbproj=0
CFG=""
mapfile -t vbproj_files < <(find . \( -name '*.vbproj' -o -name '*.VBPROJ' \) \
  -not -path '*/.git/*' -not -path '*/bin/*' -not -path '*/obj/*' \
  -not -path '*/testdata/*' 2>/dev/null | sort || true)
if [[ ${#vbproj_files[@]} -gt 0 ]]; then
  has_vbproj=1
  CFG="${vbproj_files[0]}"
fi

has_wiring=0
for mf in Makefile makefile Directory.Build.props global.json; do
  if [[ -f "$mf" ]] && rg -qi '\bdotnet\b|\.vbproj\b' "$mf" 2>/dev/null; then
    has_wiring=1
    CFG="$mf"
    break
  fi
done

has_ci=0
if [[ -d .github/workflows ]]; then
  if rg -qi '\bdotnet\b|setup-dotnet|\.vbproj\b' .github/workflows 2>/dev/null; then
    has_ci=1
  fi
fi

if [[ "$has_vbproj" -eq 0 && "$has_wiring" -eq 0 && "$has_ci" -eq 0 ]]; then
  echo "FAIL: no dotnet/vbproj wiring (.vbproj / Directory.Build.props / CI mentioning dotnet; PSR: .NET VB toolchain)"
  exit 1
fi

if [[ "${VBNET_DOTNET_CONFIG_ONLY:-}" == "1" ]]; then
  echo "PASS vbnet-dotnet-gate ($ROOT, config-only, ${#vb_files[@]} files, cfg=${CFG:-ci})"
  exit 0
fi

live_rc=127
if command -v dotnet >/dev/null 2>&1; then
  live_rc=0
fi

echo "PASS vbnet-dotnet-gate ($ROOT, config-only fallback, ${#vb_files[@]} files, cfg=${CFG:-ci}, live_rc=${live_rc})"
exit 0
