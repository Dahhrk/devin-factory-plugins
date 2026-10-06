/* Named boundary: share an immutable DateTimeFormatter, not a static SimpleDateFormat.
 * SimpleDateFormat / DateFormat hold mutable state and are not thread-safe as constants.
 * Copy into product sources; keep java-rg-allow only on intentional seams.
 */
package demo;

import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

public final class Stamp {
  private static final DateTimeFormatter STAMP =
      DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss,SSS").withZone(ZoneOffset.UTC);

  private Stamp() {}

  public static String format(Instant instant) {
    return STAMP.format(instant);
  }
}
