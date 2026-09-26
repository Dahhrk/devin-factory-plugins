#include <stdio.h>
#include <string.h>

void bad_copy(char *dst, const char *src) {
  strcpy(dst, src);
}

void bad_cat(char *dst, const char *src) {
  strcat(dst, src);
}

void bad_fmt(char *buf, int n) {
  sprintf(buf, "%d", n);
}

void bad_gets(char *buf) {
  gets(buf);
}
