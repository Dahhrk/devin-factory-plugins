#!/usr/bin/env bash
# Tier 0: banned net/Lua + Programming Standards Reference Lua checks
# (formatter/linter enforced in Tier 1/2; this gate is host/version/table/scope smells).
set -euo pipefail
ROOT="${1:-.}"
cd "$ROOT"
fail=0
check() {
  local pat="$1" msg="$2"
  if command -v rg >/dev/null 2>&1; then
    if rg -n --glob '*.lua' -e "$pat" . >/tmp/lua-rg-hits.txt 2>/dev/null; then
      echo "FAIL: $msg"
      cat /tmp/lua-rg-hits.txt
      fail=1
    fi
  else
    if grep -RIn --include='*.lua' -E "$pat" . >/tmp/lua-rg-hits.txt 2>/dev/null; then
      echo "FAIL: $msg"
      cat /tmp/lua-rg-hits.txt
      fail=1
    fi
  fi
}
# Net / Soft Dark Glass (standing)
check 'net\.WriteTable\s*\(' 'net.WriteTable banned'
check 'BroadcastLua\s*\(|:SendLua\s*\(' 'SendLua/BroadcastLua banned'
check 'net\.WriteEntity\s*\(\s*LocalPlayer\s*\(' 'client identity via WriteEntity(LocalPlayer()) banned'
check 'AddCSLuaFile\s*\(\s*["'\''][^"'\'']*sv_' 'AddCSLuaFile of sv_ path banned'
check 'util\.AddNetworkString\s*\([^)]*\).*(hook\.Add|timer\.(Create|Simple))' 'AddNetworkString near hook/timer (review)'
check '4[Aa][Aa][Cc][Ff][Cc]|Color\(\s*74\s*,\s*172\s*,\s*252' 'Soft Dark Glass cyan accent (#4AACFC) banned'

# PSR Lua ch.4: protect host boundaries
check '\b(RunString|RunStringEx|CompileString)\s*\(' 'host boundary: RunString/CompileString banned (no dynamic host code)'

# PSR Lua ch.4: table-shape conventions
check 'table\.HasValue\s*\(' 'table-shape: table.HasValue banned (use key-set / O(1) lookup)'

# PSR Lua ch.4: Lua-version / host differences (5.2+/5.3 not portable GMod 5.1)
check '(^|[^A-Za-z0-9_])goto\s+[A-Za-z_]' 'Lua-version: goto banned (portable 5.1 / GMod bar)'
check '::[A-Za-z_][A-Za-z0-9_]*::' 'Lua-version: label ::name:: banned (portable 5.1 / GMod bar)'
check '(^|[^A-Za-z0-9_])_ENV\b' 'Lua-version: _ENV banned (5.2+; GMod is 5.1 env)'
# // as 5.3 integer-div or C-style comment (prefer --); avoid matching https://
check '(^|[^:])//' 'Lua-version/style: // banned (use math.floor or --; GMod portable bar)'

# PSR / AI quality: no JS-style escaped quotes left in Lua source (agent slip)
check '\\"' 'explicit source: JS-style backslash-escaped double quote in Lua banned'
check "\\\\'" 'explicit source: JS-style backslash-escaped single quote in Lua banned'

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "PASS lua-rg-gate ($ROOT)"
