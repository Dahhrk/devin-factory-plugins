---
name: kotlin
description: Kotlin PSR bar. ktlint, detekt, no !! force unwrap, no runBlocking on hot paths, no SQL string concat. Use when reading or editing any .kt/.kts in a factory product.
paths: ["**/*.kt", "**/*.kts", "**/.editorconfig", "**/detekt.yml", "**/detekt-*.yml", "**/build.gradle.kts", "**/.github/workflows/**"]
---

# Kotlin

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Kotlin checks into product gates.

## PSR Kotlin (encoded)

1. **Agreed formatter** — ktlint (`.editorconfig` / Gradle ktlint plugin / CI). Gate: `scripts/kotlin-fmt-gate.sh`. Starter: `templates/.editorconfig`.
2. **detekt** — `detekt.yml` / CI / Gradle wiring. Gate: `scripts/kotlin-detekt-gate.sh` (wiring); run detekt in product CI when the host supports it.
3. **!! force unwrap** — no `!!` without allow. Prefer `?.` / `?:` / `requireNotNull` / smart casts. Gate: `scripts/kotlin-rg-gate.sh` (single-walk). Template: `templates/optional_bind.kt`.
4. **runBlocking** — no `runBlocking` on hot / request paths without allow. Prefer `suspend` / `coroutineScope`. Gate: `scripts/kotlin-rg-gate.sh`.
5. **SQL concat** — no SQL string concat without allow. Prefer prepared statements / named params. Gate: `scripts/kotlin-rg-gate.sh`. Template: `templates/prepared_statement.kt`.
6. **Hot-path** — `scripts/kotlin-hotpath-gate.sh` fails if rg-gate wall exceeds `KOTLIN_RG_BUDGET_MS` (default 250ms).

## Rules

- `kotlin-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-kotlin**.
