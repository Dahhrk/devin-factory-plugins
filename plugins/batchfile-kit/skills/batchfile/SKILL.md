---
name: batchfile
description: PSR Batchfile encode for product *.bat / *.cmd. Use when editing Windows batch scripts or cmd CI wiring.
disable-model-invocation: false
---

# Batchfile

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Batchfile checks into product gates.

## PSR Batchfile (encoded)

1. **Agreed toolchain** — *.bat / *.cmd / CI `cmd` / BatchScript. Gate: `scripts/bat-batch-gate.sh`. Product CI: `templates/github-workflows/bat-gates.yml`.
2. **unquoted %VAR% expansion** — no unquoted `%VAR%` in path/command contexts (`cd` / `chdir` / `call` / `start` / `if exist` / `copy` / `xcopy` / `move` / `del` / `erase` / `type` / `ren` / `rename`). Prefer `"%VAR%"` / `"%~1"`. Gate: `scripts/bat-rg-gate.sh` (single-walk). Template: `templates/quoted_var.bat`.
3. **delayedExpansion footguns** — no `EnableDelayedExpansion` with `call !cmd!` / `start !cmd!` / `cmd /c !cmd!` style untrusted expansion. Prefer quoted `%VAR%` and careful blocks; allow with rationale when required. Gate: `scripts/bat-rg-gate.sh`. Template: `templates/no_delayed_expansion.bat`.
4. **call of untrusted paths** — no `call %VAR%` / `call "%VAR%"` / `call C:\…` / `call \\unc\…` / `call http…`. Prefer static relative `call :label` / `call helper.bat`. Gate: `scripts/bat-rg-gate.sh`. Template: `templates/trusted_static_call.bat`.
5. **curl|powershell download-exec** — no `curl|powershell` / `wget|powershell` / `powershell … iex … DownloadString` / `irm` pipe-exec. Prefer checksummed local scripts. Gate: `scripts/bat-rg-gate.sh`. Template: `templates/no_curl_powershell.bat`.
6. **secrets in set** — no `set PASSWORD=` / `set SECRET=` / `set TOKEN=` / `set API_KEY=` / `set APIKEY=` / `set PRIVATE_KEY=` / `set ACCESS_KEY=` / `set AUTH=`. Prefer secret stores / CI env injection. Gate: `scripts/bat-rg-gate.sh`. Template: `templates/no_secrets_in_set.bat`.
7. **Hot-path** — `scripts/bat-hotpath-gate.sh` fails if rg-gate wall exceeds `BAT_RG_BUDGET_MS` (default 250ms).

## Rules

- `bat-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-batchfile**.
