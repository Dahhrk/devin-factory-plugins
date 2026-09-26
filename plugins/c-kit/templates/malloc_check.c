/* Named boundary: every malloc/calloc/realloc checked for NULL promptly.
 * Copy into product sources; use c-rg-allow only when a custom allocator or
 * noreturn path makes the check redundant.
 */
#include <stdlib.h>
#include <string.h>

void *alloc_or_null(size_t n) {
  void *p = malloc(n);
  if (p == NULL)
    return NULL;
  memset(p, 0, n);
  return p;
}
