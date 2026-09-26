#!/usr/bin/env bash
# Tier 1: require Roslyn analyzers / EnableNETAnalyzers where practical (PSR C#).
# Does not run analyzers (slow/host-dependent); proves config or CI wiring exists.
# Usage: bash scripts/csharp-analyzers-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
found=0

PAT='EnableNETAnalyzers|AnalysisLevel|AnalysisMode|Microsoft\.CodeAnalysis\.NetAnalyzers|Microsoft\.CodeAnalysis\.PublicApiAnalyzers|dotnet_analyzer|dotnet_diagnostic|TreatWarningsAsErrors|CodeAnalysisTreatWarningsAsErrors|RunAnalyzersDuringBuild'

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -qi -- "$PAT" "$f"; then found=1; fi
  else
    if grep -Eiq -- 'EnableNETAnalyzers|AnalysisLevel|NetAnalyzers|dotnet_analyzer' "$f"; then found=1; fi
  fi
  return 0
}

for f in Directory.Build.props Directory.Build.targets global.json NuGet.Config; do
  check_file "$f"
done

while IFS= read -r -d '' f; do
  check_file "$f"
done < <(find . -maxdepth 4 -type f \( -name '*.csproj' -o -name '*.props' -o -name '*.targets' \) -print0 2>/dev/null)

if [[ -f .editorconfig ]]; then
  if rg -qi 'dotnet_analyzer|dotnet_diagnostic|dotnet_code_quality' .editorconfig 2>/dev/null; then found=1; fi
fi

if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no Roslyn analyzers / EnableNETAnalyzers / AnalysisLevel wiring (PSR: Roslyn analyzers where practical)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS csharp-analyzers-gate ($ROOT)"
