/* Named boundary: prefer strtol family with endptr over atoi/atol/atof.
 * Copy into product sources; keep c-rg-allow only on intentional legacy seams.
 */
#include <errno.h>
#include <stdlib.h>

int parse_i32(const char *s, int *out) {
  char *end = NULL;
  long v;

  if (s == NULL || out == NULL)
    return -1;
  errno = 0;
  v = strtol(s, &end, 10);
  if (end == s || *end != '\0' || errno == ERANGE)
    return -1;
  if (v < (-2147483647 - 1) || v > 2147483647)
    return -1;
  *out = (int)v;
  return 0;
}
