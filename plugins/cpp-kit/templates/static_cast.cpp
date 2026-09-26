/* Named boundary: prefer named C++ casts over C-style casts.
 * Copy into product sources; keep cpp-rg-allow only on intentional seams.
 */
#include <cstdint>

std::int64_t widen(int x) {
  return static_cast<std::int64_t>(x);
}

const char *as_cstr(void *p) {
  return static_cast<const char *>(p);
}
