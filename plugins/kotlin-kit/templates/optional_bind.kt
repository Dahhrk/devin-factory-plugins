// Named boundary: prefer ?. / ?: / requireNotNull over !!.
// Copy into product sources; keep kotlin-rg-allow only on intentional seams.

fun firstLabel(values: List<String?>): String? {
    val first = values.firstOrNull() ?: return null
    return first
}

fun requireLabel(value: String?): String {
    return requireNotNull(value) { "label required" }
}
