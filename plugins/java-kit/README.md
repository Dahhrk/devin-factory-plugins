# java-kit

Java bar for the dark factory Cursor lane. Public research pilot: spring-projects/spring-boot (Apache-2.0).

| Surface | Path |
|---------|------|
| Skills | `skills/java`, `skills/poteto-java` |
| Rule | `rules/java.mdc` (`**/*.{java,gradle,kts}`, not alwaysApply) |
| Tier 0 | `scripts/java-rg-gate.sh` (System.out/err; printStackTrace; SQL string concat; catch NullPointerException; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/java-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `JAVA_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/java-fmt-gate.sh` (google-java-format / spotless / spring-javaformat wiring) |
| Tier 1 | `scripts/java-checkstyle-ci-gate.sh` (Checkstyle or Error Prone wiring) |
| Tier 1 | `scripts/java-nullability-gate.sh` (jspecify / NullMarked / NullAway / Checker Framework / spring Nullable) |
| Selfcheck | `scripts/java-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/java-gates.yml` + `templates/spotless.gradle` + `templates/checkstyle/checkstyle.xml` |
| Boundaries | `templates/prepared_statement.java`, `templates/logger_not_stdout.java` |

PSR Java encode (Programming Standards Reference): agreed formatter (google-java-format or Spotless; Spring Java Format accepted as google-java-format packaging); Checkstyle / Error Prone where practical; nullability contracts; no SQL/string concatenation into queries; no `System.out` / `System.err` print for product logging. Primary authority: JLS / JVMS and supported JDK documentation.

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live google-java-format when on PATH unless `JAVA_FMT_CONFIG_ONLY=1`). Checkstyle / nullability gates check wiring or annotation presence.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/java-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-java` (Java stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`java-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `java-hotpath-gate` fails if that wall exceeds `JAVA_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and spring-boot core under default budget.

### Escape

Line marker `java-rg-allow` with a short rationale. Prefer named boundaries from `templates/prepared_statement.java` / `templates/logger_not_stdout.java` over scattered allows.

## Selfcheck

`bash scripts/java-kit-selfcheck.sh` proves rg/hotpath/fmt/checkstyle/nullability gates discriminate fixtures, single-walk encode, budget discrimination (`JAVA_RG_BUDGET_MS=1`), and template presence.
