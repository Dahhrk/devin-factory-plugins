---
name: java
description: Java PSR bar. google-java-format or Spotless, Checkstyle/Error Prone where practical, nullability contracts, no System.out/err print, no printStackTrace, no SQL string concat, no catch NullPointerException. Use when reading or editing any .java / build.gradle / pom.xml in a factory product.
paths: ["**/*.java", "**/build.gradle", "**/build.gradle.kts", "**/pom.xml", "**/spotless.gradle", "**/checkstyle.xml", "**/.github/workflows/**"]
---

# Java

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Java checks into product gates.

## PSR Java (encoded)

1. **Agreed formatter** — google-java-format or Spotless (spring-javaformat accepted as google-java-format packaging). Gate: `scripts/java-fmt-gate.sh`. Starter: `templates/spotless.gradle`.
2. **Checkstyle / Error Prone where practical** — `checkstyle.xml` or checkstyle/errorprone wired in Gradle/Maven/CI. Gate: `scripts/java-checkstyle-ci-gate.sh` (wiring); run Checkstyle/Error Prone in product CI when the host supports it.
3. **Nullability contracts** — jspecify `@NullMarked` / NullAway / Checker Framework / Spring Nullable present. Gate: `scripts/java-nullability-gate.sh`.
4. **System.out/err** — no `System.out` / `System.err` print without allow. Prefer a logger. Gate: `scripts/java-rg-gate.sh` (single-walk). Template: `templates/logger_not_stdout.java`.
5. **printStackTrace** — no `printStackTrace(` without allow. Prefer logger. Gate: `scripts/java-rg-gate.sh`.
6. **SQL/string concat** — no `"SELECT..."` + / + `" WHERE..."` into queries. Prefer `PreparedStatement` / named params. Gate: `scripts/java-rg-gate.sh`. Template: `templates/prepared_statement.java`.
7. **catch NullPointerException** — banned; fix nullable contracts instead. Gate: `scripts/java-rg-gate.sh`.
8. **Hot-path** — `scripts/java-hotpath-gate.sh` fails if rg-gate wall exceeds `JAVA_RG_BUDGET_MS` (default 250ms).

## Rules

- `java-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-java**.
