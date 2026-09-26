# batchfile-kit

Batchfile (.bat / .cmd) bar for the dark factory Cursor lane. Public research pilot: npocmaka/batch.scripts (MIT) Windows batch corpus (delayedExpansion, password/set surfaces, powershell hybrids) plus intentional smell fixtures.

| Surface | Path |
|---------|------|
| Skills | `skills/batchfile`, `skills/poteto-batchfile` |
| Rule | `rules/batchfile.mdc` (`**/*.bat`, `**/*.cmd`, not alwaysApply) |
| Tier 0 | `scripts/bat-rg-gate.sh` (unquoted %VAR% expansion; delayedExpansion footguns; call of untrusted paths; curl\|powershell download-exec; secrets in set; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/bat-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `BAT_RG_BUDGET_MS`) |
| Tier 1 | `scripts/bat-batch-gate.sh` (*.bat / *.cmd / CI cmd.exe|batch wiring / live `cmd.exe` / `wine cmd` when resolvable) |
| Selfcheck | `scripts/batchfile-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/bat-gates.yml` |
| Boundaries | `templates/quoted_var.bat`, `templates/no_delayed_expansion.bat`, `templates/trusted_static_call.bat`, `templates/no_curl_powershell.bat`, `templates/no_secrets_in_set.bat` |

PSR Batchfile encode (Programming Standards Reference): never unquoted `%VAR%` in path/command contexts (`cd` / `call` / `if exist` / `copy` / …); never `EnableDelayedExpansion` footguns (`call !cmd!` / enabling delayed expansion for untrusted expansion); never `call` of untrusted `%VAR%` / absolute / UNC paths; never `curl|powershell` / `iex DownloadString` download-exec; never secrets in `set PASSWORD=` / `set SECRET=` / `set TOKEN=` / `set API_KEY=`. Primary authority: npocmaka/batch.scripts (MIT) + intentional fixtures — Microsoft Learn BatchScript docs are documentation-only (no single permissive sample repo).

Compose with `/poteto-mode`. Tier 1 checks batch wiring (live cmd when resolvable unless `BAT_BATCH_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/batchfile-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-batchfile` (Batchfile / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`bat-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `bat-hotpath-gate` fails if that wall exceeds `BAT_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `bat-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer quoted `"%VAR%"` / `"%~1"`. Prefer static relative `call :label` / `call helper.bat`. Prefer no `EnableDelayedExpansion` unless necessary with allow. Prefer local checksum scripts over pipe-to-powershell. Prefer env injection / secret stores over `set PASSWORD=`.

## Selfcheck

`bash scripts/batchfile-kit-selfcheck.sh` proves rg/hotpath/batch gates discriminate fixtures, single-walk encode, budget discrimination (`BAT_RG_BUDGET_MS=1`), batch wiring bar, and template presence.
