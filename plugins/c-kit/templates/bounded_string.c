/* Named boundary: prefer snprintf / bounded copies over strcpy/sprintf.
 * Copy into product sources; keep c-rg-allow only on intentional legacy seams.
 */
#include <stdio.h>
#include <string.h>

int copy_bounded(char *dst, size_t dst_sz, const char *src) {
  if (dst == NULL || dst_sz == 0)
    return -1;
  int n = snprintf(dst, dst_sz, "%s", src ? src : "");
  if (n < 0 || (size_t)n >= dst_sz)
    return -1;
  return n;
}
