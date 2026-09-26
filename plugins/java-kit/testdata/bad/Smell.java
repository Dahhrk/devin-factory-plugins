package demo;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class Smell {
  public void logBad() {
    System.out.println("bad");
  }

  public void stackBad(Exception ex) {
    ex.printStackTrace();
  }

  public ResultSet sqlBad(Connection conn, String id) throws Exception {
    Statement st = conn.createStatement();
    return st.executeQuery("SELECT * FROM users WHERE id = " + id);
  }

  public int npeBad(String s) {
    try {
      return s.length();
    }
    catch (NullPointerException ex) {
      return 0;
    }
  }
}
