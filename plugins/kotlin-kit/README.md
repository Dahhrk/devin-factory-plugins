# kotlin-kit

Kotlin bar for the dark factory Cursor lane. Public research pilot: ktorio/ktor (Apache-2.0).

| Surface | Path |
|---------|------|
| Skills | `skills/kotlin`, `skills/poteto-kotlin` |
| Rule | `rules/kotlin.mdc` (`**/*.{kt,kts}`, not alwaysApply) |
| Tier 0 | `scripts/kotlin-rg-gate.sh` (`!!`; `runBlocking`; SQL concat; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/kotlin-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `KOTLIN_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/kotlin-fmt-gate.sh` (ktlint wiring / live) |
| Tier 1 | `scripts/kotlin-detekt-gate.sh` (detekt wiring) |
| Selfcheck | `scripts/kotlin-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/kotlin-gates.yml` + `templates/.editorconfig` / `templates/detekt.yml` |
| Boundaries | `templates/optional_bind.kt`, `templates/prepared_statement.kt` |

PSR Kotlin encode (Programming Standards Reference): ktlint; detekt; no `!!` force unwrap without allow; no `runBlocking` on hot paths without allow; no SQL string concat. Primary authority: Kotlin language docs and JetBrains tooling (ktlint, detekt).

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live `ktlint` when on PATH unless `KOTLIN_FMT_CONFIG_ONLY=1`). Detekt gate checks detekt config / CI / Gradle wiring.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/kotlin-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-kotlin` (Kotlin stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`kotlin-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `kotlin-hotpath-gate` fails if that wall exceeds `KOTLIN_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and ktorio/ktor (ktor-server-core + ktor-utils + ktor-http + ktor-io + ktor-network) under default budget.

### Escape

Line marker `kotlin-rg-allow` with a short rationale. Prefer named boundaries from `templates/optional_bind.kt` / `templates/prepared_statement.kt` over scattered allows.

## Selfcheck

`bash scripts/kotlin-kit-selfcheck.sh` proves rg/hotpath/fmt/detekt gates discriminate fixtures, single-walk encode, budget discrimination (`KOTLIN_RG_BUDGET_MS=1`), and template presence.
