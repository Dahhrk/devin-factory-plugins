#!/usr/bin/env bash
# Tier 0.5 hot-path smells. Prefer Iterator over GetAll. No Color/Material/Vector/Angle
# after the first hot hook.Add in that file. Annotate intentional lines with hotpath-allow.
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

if command -v rg >/dev/null 2>&1; then
  search() { rg -n --glob '*.lua' -e "$1" "${@:2}"; }
  search_l() { rg -l --glob '*.lua' -e "$1" .; }
else
  search() { grep -RIn --include='*.lua' -E "$1" "${@:2}"; }
  search_l() { grep -RIl --include='*.lua' -E "$1" .; }
fi

if search 'player\.GetAll\s*\(|ents\.GetAll\s*\(' . 2>/dev/null | grep -v 'hotpath-allow' >"$tmp" || true; then
  if [[ -s "$tmp" ]]; then
    echo "FAIL: player.GetAll / ents.GetAll (prefer Iterator; annotate hotpath-allow if intentional)"
    cat "$tmp"
    fail=1
  fi
fi

hot_files=$(search_l 'hook\.Add\s*\(\s*["'"'"'](Think|Tick|HUDPaint|CreateMove)' 2>/dev/null || true)
for f in $hot_files; do
  [[ -f "$f" ]] || continue
  hook_line=$(search 'hook\.Add\s*\(\s*["'"'"'](Think|Tick|HUDPaint|CreateMove)' "$f" 2>/dev/null | head -1 | cut -d: -f1 || true)
  [[ -n "${hook_line:-}" ]] || continue
  hits=$(search '\bColor\s*\(|\bMaterial\s*\(|\bVector\s*\(|\bAngle\s*\(' "$f" 2>/dev/null | awk -F: -v hl="$hook_line" '$1+0 > hl+0 {print}' || true)
  if [[ -n "$hits" ]]; then
    echo "FAIL: alloc constructor after hot hook in $f (cache at file scope)"
    echo "$hits"
    fail=1
  fi
done

# Soft Dark Glass: Onyx cyan accent banned
if search '4[Aa][Aa][Cc][Ff][Cc]|Color\(\s*74\s*,\s*172\s*,\s*252' . 2>/dev/null | grep -v 'hotpath-allow' >"$tmp" || true; then
  if [[ -s "$tmp" ]]; then
    echo "FAIL: Soft Dark Glass cyan accent (#4AACFC) banned"
    cat "$tmp"
    fail=1
  fi
fi


# No fresh table literal as Paint*Ring opts (cache on panel / EmptyRingOpts)
if search 'Paint(Avatar|Occupancy)Ring\([^)]*\{' . 2>/dev/null | grep -v 'hotpath-allow' >"$tmp" || true; then
  if [[ -s "$tmp" ]]; then
    echo "FAIL: inline table opts to Paint*Ring (cache on panel or EmptyRingOpts)"
    cat "$tmp"
    fail=1
  fi
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS lua-hotpath-gate ($ROOT)"
