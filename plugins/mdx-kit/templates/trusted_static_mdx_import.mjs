// Named boundary: import trusted .mdx as a module; do not evaluate user strings.
// Anti-pattern (banned without allow): await evaluate(req.body, runtime)
import Content from './posts/hello.mdx'

export function renderPost() {
  return Content
}
