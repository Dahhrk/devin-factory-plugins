/* Named boundary: prefer a logger over System.out/err and printStackTrace.
 * Copy into product sources; keep java-rg-allow only on intentional seams.
 */
package demo;

import java.lang.System.Logger;
import java.lang.System.Logger.Level;

public final class AppLog {
  private static final Logger LOG = System.getLogger(AppLog.class.getName());

  private AppLog() {}

  public static void info(String message) {
    LOG.log(Level.INFO, message);
  }

  public static void error(String message, Throwable error) {
    LOG.log(Level.ERROR, message, error);
  }
}
