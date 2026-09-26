#!/usr/bin/env bash
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
check() {
  local pat="$1" msg="$2"
  if command -v rg >/dev/null 2>&1; then
    if rg -n --glob '*.lua' -e "$pat" . >/tmp/gmod-rg-hits.txt 2>/dev/null; then
      echo "FAIL: $msg"
      cat /tmp/gmod-rg-hits.txt
      fail=1
    fi
  else
    if grep -RIn --include='*.lua' -E "$pat" . >/tmp/gmod-rg-hits.txt 2>/dev/null; then
      echo "FAIL: $msg"
      cat /tmp/gmod-rg-hits.txt
      fail=1
    fi
  fi
}
check 'net\.WriteTable\s*\(' 'net.WriteTable banned'
check 'BroadcastLua\s*\(|:SendLua\s*\(' 'SendLua/BroadcastLua banned'
check 'net\.WriteEntity\s*\(\s*LocalPlayer\s*\(' 'client identity via WriteEntity(LocalPlayer()) banned'
check 'AddCSLuaFile\s*\(\s*["'\''][^"'\'']*sv_' 'AddCSLuaFile of sv_ path banned'
check 'util\.AddNetworkString\s*\([^)]*\).*(hook\.Add|timer\.(Create|Simple))' 'AddNetworkString near hook/timer (review)'
if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS gmod-rg-gate ($ROOT)"
