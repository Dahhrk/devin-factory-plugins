// Intentional smells for mdx-rg-gate discrimination (not product code).
import {evaluate} from '@mdx-js/mdx'
import rehypeRaw from 'rehype-raw'
import * as runtime from 'react/jsx-runtime'

export async function renderUser(body) {
  return evaluate(body, {...runtime})
}

export const plugins = [rehypeRaw]
