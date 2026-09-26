#!/usr/bin/env bash
# Tier 1: require nullable reference analysis (PSR C#: nullable enable).
# Passes when <Nullable>enable</Nullable> / #nullable enable / Nullable context
# is present. Escape: CSHARP_NULLABLE_GATE_SKIP=1.
# Usage: bash scripts/csharp-nullable-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${CSHARP_NULLABLE_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS csharp-nullable-gate (skipped via CSHARP_NULLABLE_GATE_SKIP=1)"
  exit 0
fi

found=0

# Project / Directory.Build.props
PAT='<Nullable>\s*enable\s*</Nullable>|Nullable\s*=\s*"?enable"?'
for f in Directory.Build.props Directory.Build.targets; do
  [[ -f "$f" ]] || continue
  if rg -qi -- "$PAT" "$f" 2>/dev/null; then found=1; fi
done

while IFS= read -r -d '' f; do
  if rg -qi -- "$PAT" "$f" 2>/dev/null; then found=1; fi
done < <(find . -maxdepth 4 -type f -name '*.csproj' -print0 2>/dev/null)

# Source #nullable enable (product sources)
if command -v rg >/dev/null 2>&1; then
  if rg -q --glob '*.cs' --glob '!**/test/**' --glob '!**/*Test.cs' \
      '#nullable[[:space:]]+enable' . 2>/dev/null; then
    found=1
  fi
fi

if [[ -d .github/workflows ]]; then
  if rg -qi 'nullable|Nullable' .github/workflows 2>/dev/null; then found=1; fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no nullable enable (<Nullable>enable</Nullable> or #nullable enable in sources/build) (PSR: nullable reference analysis)"
  exit 1
fi
echo "PASS csharp-nullable-gate ($ROOT)"
