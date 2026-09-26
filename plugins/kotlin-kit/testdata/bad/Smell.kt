// Intentional smells for kotlin-rg-gate discrimination (not product code).

fun forceBad(value: String?): String {
    return value!!
}

fun blockBad(): Int {
    return runBlocking {
        1
    }
}

fun sqlBad(id: Long): String {
    return "SELECT name FROM users WHERE id = " + id
}
