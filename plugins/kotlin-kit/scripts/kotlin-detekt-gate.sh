#!/usr/bin/env bash
# Tier 1: require detekt wiring (PSR Kotlin language-farm).
# Does not run the analyzer (host-dependent); proves detekt.yml or CI/Gradle.
# Escape: KOTLIN_DETEKT_GATE_SKIP=1.
# Usage: bash scripts/kotlin-detekt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${KOTLIN_DETEKT_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS kotlin-detekt-gate (skipped via KOTLIN_DETEKT_GATE_SKIP=1)"
  exit 0
fi

found=0

# Config files
for f in detekt.yml detekt.yaml config/detekt/detekt.yml config/detekt.yml .detekt.yml; do
  if [[ -f "$f" ]]; then found=1; fi
done

# Nested configs (monorepo / packages)
if [[ "$found" -eq 0 ]]; then
  if find . -maxdepth 4 -type f \( -name 'detekt.yml' -o -name 'detekt.yaml' -o -name 'detekt-*.yml' \) \
      -not -path '*/.git/*' -not -path '*/build/*' 2>/dev/null \
      | head -1 | rg -q .; then
    found=1
  fi
fi

# Gradle / Maven detekt plugin
for f in build.gradle build.gradle.kts settings.gradle.kts gradle.properties pom.xml; do
  if [[ -f "$f" ]] && rg -qi 'detekt|io\.gitlab\.arturbosch\.detekt' "$f" 2>/dev/null; then
    found=1
  fi
done
if [[ -d buildSrc ]] && rg -qi 'detekt|io\.gitlab\.arturbosch\.detekt' buildSrc --glob '*.{kt,kts,gradle}' 2>/dev/null; then
  found=1
fi

# CI mentions
if [[ "$found" -eq 0 ]] && [[ -d .github/workflows ]]; then
  if rg -qi 'detekt' .github/workflows 2>/dev/null; then
    found=1
  fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no detekt wiring (detekt.yml / config/detekt or CI / Gradle; PSR language-farm requires detekt)"
  exit 1
fi
echo "PASS kotlin-detekt-gate ($ROOT)"
