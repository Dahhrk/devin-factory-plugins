// Good fixture: optional bind, documented allow.

fun firstOk(values: List<String?>): String? {
    return values.firstOrNull() ?: "missing"
}

fun tryOk(raw: String): Int {
    return requireNotNull(raw.toIntOrNull()) { "bad int" }
}

// Documented intentional seam (boot probe); keep allow on the smell line.
fun documentedLegacy(value: String?): String {
    return value!! // kotlin-rg-allow: fixture documents allow marker for intentional force unwrap seam
}
