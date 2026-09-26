package demo;

import java.lang.System.Logger;
import java.lang.System.Logger.Level;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@org.jspecify.annotations.NullMarked
public class Ok {
  private static final Logger LOG = System.getLogger(Ok.class.getName());

  public void logOk(String message) {
    LOG.log(Level.INFO, message);
  }

  public ResultSet sqlOk(Connection conn, long id) throws Exception {
    PreparedStatement ps = conn.prepareStatement("SELECT name FROM users WHERE id = ?");
    ps.setLong(1, id);
    return ps.executeQuery();
  }

  /* Named boundary docs; intentional legacy uses java-rg-allow on the smell line. */
  public void documentedLegacy() {
    System.out.println("boot banner"); /* java-rg-allow: process bootstrap before logger binds */
  }
}
