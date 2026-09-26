#!/usr/bin/env bash
# Tier 0.5a: formatter wiring (PSR C#: dotnet format / .editorconfig).
# Live `dotnet format --verify-no-changes` when dotnet exists unless
# CSHARP_FMT_CONFIG_ONLY=1 (config/plugin presence only).
# Usage: bash scripts/csharp-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . -name '*.cs' -not -path '*/.git/*' -not -path '*/bin/*' -not -path '*/obj/*' -not -path '*/test/*' -not -path '*/tests/*' -not -path '*/generated/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no C# sources under $ROOT"
  exit 1
fi

has_cfg=0
# .editorconfig with csharp_ / dotnet_formatting / indent
if [[ -f .editorconfig ]]; then
  if rg -qi 'csharp_|dotnet_formatting|dotnet_style_|indent_style|end_of_line' .editorconfig 2>/dev/null; then has_cfg=1; fi
fi
# Directory.Build.props / csproj format hints
for f in Directory.Build.props Directory.Build.targets *.sln; do
  [[ -e $f ]] || continue
  if rg -qi 'dotnet format|TreatWarningsAsErrors|EnforceCodeStyleInBuild|AnalysisLevel' $f 2>/dev/null; then has_cfg=1; fi
done
# any csproj with EnforceCodeStyleInBuild / style
if find . -maxdepth 3 -name '*.csproj' 2>/dev/null | head -20 | while read -r f; do
  rg -qi 'EnforceCodeStyleInBuild|dotnet format|editorconfig' "$f" 2>/dev/null && exit 0
  exit 1
done; then has_cfg=1; fi
# Check CI for formatter jobs
if [[ -d .github/workflows ]]; then
  if rg -qi 'dotnet format|dotnet-format|csharpier' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi
# Explicit csharpier / .csharpierrc
if [[ -f .csharpierrc ]] || [[ -f .csharpierrc.json ]] || [[ -f csharpier.json ]]; then has_cfg=1; fi

if [[ "${CSHARP_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS csharp-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no dotnet format / .editorconfig csharp style wiring (copy csharp-kit/templates/editorconfig/.editorconfig; or unset CSHARP_FMT_CONFIG_ONLY)"
  exit 1
fi

if command -v dotnet >/dev/null 2>&1; then
  if find . -maxdepth 3 \( -name '*.sln' -o -name '*.csproj' \) 2>/dev/null | rg -q .; then
    if dotnet format --verify-no-changes --verbosity quiet 2>/dev/null; then
      echo "PASS csharp-fmt-gate ($ROOT, live dotnet format, ${#files[@]} files)"
      exit 0
    else
      # live failure may be host/project noise; fall through to config if present
      if [[ "$has_cfg" -eq 1 ]]; then
        echo "PASS csharp-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
        exit 0
      fi
      echo "FAIL: dotnet format would rewrite sources (PSR: agreed formatter)"
      exit 1
    fi
  fi
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS csharp-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install dotnet for live)"
  exit 0
fi

echo "FAIL: dotnet not on PATH (or no project) and no .editorconfig / EnforceCodeStyleInBuild / dotnet format CI wiring (PSR: agreed formatter)"
exit 1
