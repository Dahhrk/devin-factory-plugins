---
name: powershell
description: PowerShell PSR bar. PSScriptAnalyzer lint, no Invoke-Expression, no Write-Host in modules, no unquoted paths. Use when reading or editing any .ps1/.psm1 in a factory product.
paths: ["**/*.ps1", "**/*.psm1", "**/*.PS1", "**/*.PSM1", "**/PSScriptAnalyzerSettings.psd1", "**/.github/workflows/**"]
---

# PowerShell

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference PowerShell checks into product gates.

## PSR PowerShell (encoded)

1. **Agreed linter** — `PSScriptAnalyzer` (`PSScriptAnalyzerSettings.psd1` / settings / CI `Invoke-ScriptAnalyzer` / live). Gate: `scripts/ps-pssa-gate.sh`. Product CI: `templates/github-workflows/ps-gates.yml`. Config must keep **PSAvoidUsingInvokeExpression** and **PSAvoidUsingWriteHost** enabled (not excluded).
2. **Invoke-Expression** — no `Invoke-Expression` / `iex` without allow. Prefer `&` call operator / splatting. Gate: `scripts/ps-rg-gate.sh` (single-walk). Template: `templates/no_iex.ps1`.
3. **Write-Host in modules** — no `Write-Host` in `.psm1` without allow. Prefer `Write-Output` / information stream / structured logging. Gate: `scripts/ps-rg-gate.sh`. Template: `templates/write_output_not_host.psm1`.
4. **Unquoted paths** — no unquoted path cmdlet args (`Test-Path $p`, `Get-Content $p`, `Set-Location $p`, …) without allow. Quote `"$path"`. Gate: `scripts/ps-rg-gate.sh`. Template: `templates/quoted_path.ps1`.
5. **Hot-path** — `scripts/ps-hotpath-gate.sh` fails if rg-gate wall exceeds `PS_RG_BUDGET_MS` (default 250ms).

## Rules

- `ps-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-powershell**.
