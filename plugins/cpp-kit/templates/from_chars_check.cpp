/* Named boundary: parse numbers with error reporting, not atoi/atol/atof.
 * atoi family returns 0 on garbage and has undefined behaviour on overflow.
 * Copy into product sources; keep cpp-rg-allow only on intentional seams.
 */
#include <charconv>
#include <optional>
#include <string_view>
#include <system_error>

std::optional<int> parse_int(std::string_view s) {
  int value = 0;
  const auto [end, ec] = std::from_chars(s.data(), s.data() + s.size(), value);
  if (ec != std::errc() || end != s.data() + s.size()) return std::nullopt;
  return value;
}
