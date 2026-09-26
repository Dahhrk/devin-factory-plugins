#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *dup_bounded(const char *src, size_t cap) {
  char *p = malloc(cap);
  if (p == NULL)
    return NULL;
  snprintf(p, cap, "%s", src);
  return p;
}

/* Named boundary docs; intentional legacy uses c-rg-allow on the smell line. */
void documented_legacy(char *dst, const char *src) {
  strcpy(dst, src); /* c-rg-allow: sized by caller contract; prefer snprintf */
}
