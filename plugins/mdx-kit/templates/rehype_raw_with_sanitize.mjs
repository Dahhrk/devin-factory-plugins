// Named boundary: if rehype-raw is required, pair with rehype-sanitize.
// Anti-pattern (banned without allow): rehypePlugins: [rehypeRaw] alone
import {compile} from '@mdx-js/mdx'
import rehypeRaw from 'rehype-raw'
import rehypeSanitize from 'rehype-sanitize'

export async function compileTrusted(src) {
  return compile(src, {
    rehypePlugins: [rehypeRaw, rehypeSanitize],
  })
}
