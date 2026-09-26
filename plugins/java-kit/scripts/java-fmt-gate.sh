#!/usr/bin/env bash
# Tier 0.5a: formatter wiring (PSR Java: google-java-format or Spotless).
# Accepts google-java-format, Spotless, or spring-javaformat (google-java-format packaging).
# Live `google-java-format --dry-run --set-exit-if-changed` when tool exists unless
# JAVA_FMT_CONFIG_ONLY=1 (config/plugin presence only).
# Usage: bash scripts/java-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . -name '*.java' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/target/*' -not -path '*/out/*' -not -path '*/test/*' -not -path '*/tests/*' -not -path '*/generated/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Java sources under $ROOT"
  exit 1
fi

has_cfg=0
# Spotless
if [[ -f spotless.gradle ]] || [[ -f spotless.gradle.kts ]]; then has_cfg=1; fi
if [[ -f build.gradle ]] && rg -qi 'spotless|com\.diffplug\.spotless' build.gradle 2>/dev/null; then has_cfg=1; fi
if [[ -f build.gradle.kts ]] && rg -qi 'spotless|com\.diffplug\.spotless' build.gradle.kts 2>/dev/null; then has_cfg=1; fi
# google-java-format plugin / config
if [[ -f .google-java-format ]] || [[ -f google-java-format.json ]]; then has_cfg=1; fi
if [[ -f build.gradle ]] && rg -qi 'google-java-format|googlejavaformat|com\.github\.sherter\.google-java-format' build.gradle 2>/dev/null; then has_cfg=1; fi
if [[ -f build.gradle.kts ]] && rg -qi 'google-java-format|googlejavaformat' build.gradle.kts 2>/dev/null; then has_cfg=1; fi
if [[ -f pom.xml ]] && rg -qi 'google-java-format|spotless-maven-plugin|fmt-maven-plugin' pom.xml 2>/dev/null; then has_cfg=1; fi
# spring-javaformat (google-java-format packaging used by Spring)
if [[ -f build.gradle ]] && rg -qi 'spring-javaformat|io\.spring\.javaformat' build.gradle 2>/dev/null; then has_cfg=1; fi
if [[ -f build.gradle.kts ]] && rg -qi 'spring-javaformat|io\.spring\.javaformat' build.gradle.kts 2>/dev/null; then has_cfg=1; fi
if [[ -f buildSrc/build.gradle ]] && rg -qi 'spring-javaformat|io\.spring\.javaformat|google-java-format|spotless' buildSrc/build.gradle 2>/dev/null; then has_cfg=1; fi
if [[ -f gradle.properties ]] && rg -qi 'javaFormatVersion|spotless|googleJavaFormat' gradle.properties 2>/dev/null; then has_cfg=1; fi
# Check CI for formatter jobs
if [[ -d .github/workflows ]]; then
  if rg -qi 'google-java-format|spotless|spring-javaformat|googlejavaformat' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi

if [[ "${JAVA_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS java-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no google-java-format / Spotless / spring-javaformat wiring (copy java-kit/templates/spotless.gradle; or unset JAVA_FMT_CONFIG_ONLY)"
  exit 1
fi

if command -v google-java-format >/dev/null 2>&1; then
  if google-java-format --dry-run --set-exit-if-changed "${files[@]}" 2>/dev/null; then
    echo "PASS java-fmt-gate ($ROOT, live google-java-format, ${#files[@]} files)"
    exit 0
  else
    echo "FAIL: google-java-format would rewrite sources (PSR: agreed formatter)"
    exit 1
  fi
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS java-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install google-java-format for live)"
  exit 0
fi

echo "FAIL: google-java-format not on PATH and no Spotless/google-java-format/spring-javaformat wiring (PSR: agreed formatter)"
exit 1
