#include <memory>
#include <cstdint>

std::unique_ptr<int> make_int(int v) {
  return std::make_unique<int>(v);
}

std::int64_t widen(int x) {
  return static_cast<std::int64_t>(x);
}

/* Named boundary docs; intentional legacy uses cpp-rg-allow on the smell line. */
int *documented_legacy(int n) {
  return new int[n]; /* cpp-rg-allow: sized by caller contract; prefer unique_ptr */
}
