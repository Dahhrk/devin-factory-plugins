#include <cstdio>
#include <cstdlib>

int *bad_new(int n) {
  return new int[n];
}

void bad_delete(int *p) {
  delete[] p;
}

int bad_cast(void *p) {
  return *(int *)p;
}

int bad_numeric(double x) {
  return (int)x;
}

void bad_fmt(char *buf, int n) {
  sprintf(buf, "%d", n);
}
