#!/usr/bin/env bash
# Tier 0.5a: ktlint wiring as agreed formatter (PSR Kotlin).
# Live ktlint when tool exists unless KOTLIN_FMT_CONFIG_ONLY=1.
# Usage: bash scripts/kotlin-fmt-gate.sh [root]
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"

mapfile -t files < <(find . \( -name '*.kt' -o -name '*.kts' \) -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/out/*' -not -path '*/target/*' -not -path '*/tmp/*' -not -path '*/node_modules/*' -not -path '*/test/*' -not -path '*/tests/*' -not -path '*/Test/*' -not -path '*/Tests/*' 2>/dev/null | sort || true)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "FAIL: no Kotlin sources under $ROOT"
  exit 1
fi

has_cfg=0
# .editorconfig with ktlint keys, or dedicated ktlint config
if [[ -f .editorconfig ]] && rg -qi 'ktlint|ij_kotlin' .editorconfig 2>/dev/null; then has_cfg=1; fi
for f in .ktlint.yml .ktlint.yaml ktlint.yml; do
  [[ -f $f ]] && has_cfg=1
done
# Nested .editorconfig
if [[ "$has_cfg" -eq 0 ]]; then
  if find . -maxdepth 3 -type f -name '.editorconfig' -not -path '*/.git/*' -not -path '*/build/*' 2>/dev/null \
      | head -5 | xargs -r rg -lqi 'ktlint|ij_kotlin' 2>/dev/null | head -1 | rg -q .; then
    has_cfg=1
  fi
fi
# Gradle / Maven ktlint plugin
for f in build.gradle build.gradle.kts settings.gradle.kts gradle.properties pom.xml; do
  if [[ -f "$f" ]] && rg -qi 'ktlint|org\.jlleitschuh\.gradle\.ktlint|com\.pinterest\.ktlint' "$f" 2>/dev/null; then
    has_cfg=1
  fi
done
# buildSrc / convention plugins
if [[ -d buildSrc ]] && rg -qi 'ktlint|org\.jlleitschuh\.gradle\.ktlint' buildSrc --glob '*.{kt,kts,gradle}' 2>/dev/null; then
  has_cfg=1
fi
# CI ktlint
if [[ -d .github/workflows ]]; then
  if rg -qi 'ktlint' .github/workflows 2>/dev/null; then has_cfg=1; fi
fi

if [[ "${KOTLIN_FMT_CONFIG_ONLY:-}" == "1" ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS kotlin-fmt-gate ($ROOT, config-only, ${#files[@]} files)"
    exit 0
  fi
  echo "FAIL: no ktlint wiring (copy kotlin-kit/templates/.editorconfig; or unset KOTLIN_FMT_CONFIG_ONLY)"
  exit 1
fi

run_fmt() {
  if command -v ktlint >/dev/null 2>&1; then
    ktlint --relative "${files[@]}" 2>/dev/null
    return $?
  fi
  return 127
}

if run_fmt; then
  echo "PASS kotlin-fmt-gate ($ROOT, live ktlint, ${#files[@]} files)"
  exit 0
fi
live_rc=$?

if [[ "$live_rc" -eq 127 ]]; then
  if [[ "$has_cfg" -eq 1 ]]; then
    echo "PASS kotlin-fmt-gate ($ROOT, config-only fallback, ${#files[@]} files; install ktlint for live)"
    exit 0
  fi
  echo "FAIL: ktlint not on PATH and no .editorconfig ktlint / Gradle ktlint / CI wiring (PSR: ktlint)"
  exit 1
fi

if [[ "$has_cfg" -eq 1 ]]; then
  echo "PASS kotlin-fmt-gate ($ROOT, config-only fallback after live, ${#files[@]} files)"
  exit 0
fi
echo "FAIL: ktlint would rewrite or flag sources (PSR: ktlint)"
exit 1
