// Named boundary: prefer PreparedStatement over SQL string concat.
// Copy into product sources; keep kotlin-rg-allow only on intentional seams.

import java.sql.Connection

fun findName(conn: Connection, id: Long): String? {
    conn.prepareStatement("SELECT name FROM users WHERE id = ?").use { ps ->
        ps.setLong(1, id)
        ps.executeQuery().use { rs ->
            return if (rs.next()) rs.getString(1) else null
        }
    }
}
