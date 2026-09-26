/* Named boundary: prefer unique_ptr / make_unique over raw new/delete.
 * Copy into product sources; keep cpp-rg-allow only on intentional seams.
 */
#include <memory>

struct Node {
  int value;
};

std::unique_ptr<Node> make_node(int v) {
  auto p = std::make_unique<Node>();
  p->value = v;
  return p;
}
