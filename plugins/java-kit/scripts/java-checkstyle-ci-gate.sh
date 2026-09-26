#!/usr/bin/env bash
# Tier 1: require Checkstyle or Error Prone wiring where practical (PSR Java).
# Does not run Checkstyle/Error Prone (slow/host-dependent); proves config or
# plugin/CI wiring exists.
# Usage: bash scripts/java-checkstyle-ci-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
found=0

if [[ -f checkstyle.xml ]] || [[ -f config/checkstyle/checkstyle.xml ]] || [[ -f .checkstyle ]]; then
  found=1
fi
if [[ -d config/checkstyle ]] && find config/checkstyle -name '*.xml' 2>/dev/null | rg -q .; then
  found=1
fi

PAT='checkstyle|error[- ]?prone|net\.ltgt\.errorprone|com\.google\.errorprone'

check_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  if command -v rg >/dev/null 2>&1; then
    if rg -qi -- "$PAT" "$f"; then found=1; fi
  else
    if grep -Eiq -- 'checkstyle|error.?prone' "$f"; then found=1; fi
  fi
  return 0
}

for f in build.gradle build.gradle.kts pom.xml buildSrc/build.gradle gradle.properties; do
  check_file "$f"
done

if [[ -d .github/workflows ]]; then
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find .github/workflows -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
fi

if [[ "$found" -eq 0 ]]; then
  echo "FAIL: no Checkstyle or Error Prone wiring (checkstyle.xml or checkstyle/errorprone in Gradle/Maven/CI) (PSR: Checkstyle/Error Prone where practical)"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS java-checkstyle-ci-gate ($ROOT)"
