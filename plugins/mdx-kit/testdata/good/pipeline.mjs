import {compile} from '@mdx-js/mdx'
import rehypeRaw from 'rehype-raw'
import rehypeSanitize from 'rehype-sanitize'
import Content from './ok.mdx'

export async function build(src) {
  return compile(src, {rehypePlugins: [rehypeRaw, rehypeSanitize]})
}

export function render() {
  return Content
}
