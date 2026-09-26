#!/usr/bin/env bash
# Tier 1: require nullability contracts (PSR Java: null contracts).
# Passes when jspecify / @NullMarked / NullAway / Checker Framework / Spring
# Nullable tooling or annotations are present. Escape: JAVA_NULLABILITY_GATE_SKIP=1.
# Usage: bash scripts/java-nullability-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

if [[ "${JAVA_NULLABILITY_GATE_SKIP:-}" == "1" ]]; then
  echo "PASS java-nullability-gate (skipped via JAVA_NULLABILITY_GATE_SKIP=1)"
  exit 0
fi

found=0

# Annotation / package marker presence in sources
if command -v rg >/dev/null 2>&1; then
  if rg -q --glob '*.java' --glob '!**/test/**' --glob '!**/*Test.java' \
      '@NullMarked|org\.jspecify\.annotations|org\.checkerframework|com\.uber\.nullaway|org\.springframework\.lang\.(Nullable|NonNull)|jakarta\.annotation\.(Nullable|Nonnull)|javax\.annotation\.(Nullable|Nonnull)' \
      . 2>/dev/null; then
    found=1
  fi
fi

# Tooling wiring in build
PAT='jspecify|NullAway|nullaway|checkerframework|checker-qual|spotbugs|errorprone|org\.springframework\.lang|jakarta\.annotation'
for f in build.gradle build.gradle.kts pom.xml buildSrc/build.gradle gradle.properties; do
  [[ -f "$f" ]] || continue
  if rg -qi -- "$PAT" "$f" 2>/dev/null; then found=1; fi
done

if [[ -d .github/workflows ]]; then
  if rg -qi -- "$PAT|NullAway|jspecify" .github/workflows 2>/dev/null; then found=1; fi
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no nullability contracts (jspecify/@NullMarked/NullAway/Checker Framework/Spring Nullable in sources or build) (PSR: null contracts)"
  exit 1
fi
echo "PASS java-nullability-gate ($ROOT)"
