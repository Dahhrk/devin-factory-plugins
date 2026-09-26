/* Named boundary: prefer PreparedStatement over SQL string concat.
 * Copy into product sources; keep java-rg-allow only on intentional seams.
 */
package demo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public final class PreparedLookup {
  private PreparedLookup() {}

  public static String findName(Connection conn, long id) throws SQLException {
    try (PreparedStatement ps = conn.prepareStatement("SELECT name FROM users WHERE id = ?")) {
      ps.setLong(1, id);
      try (ResultSet rs = ps.executeQuery()) {
        return rs.next() ? rs.getString(1) : null;
      }
    }
  }
}
