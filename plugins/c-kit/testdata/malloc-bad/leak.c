#include <stdlib.h>

void *unchecked(size_t n) {
  void *p = malloc(n);
  return p;
}
