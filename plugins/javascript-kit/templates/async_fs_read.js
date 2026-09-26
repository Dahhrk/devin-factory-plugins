/* Named boundary: prefer fs.promises over sync fs on request path.
 * Copy into product sources; keep js-rg-allow only on intentional seams.
 */
import { readFile } from 'node:fs/promises';

/**
 * @param {string} path
 * @returns {Promise<string>}
 */
export async function readText(path) {
  return readFile(path, 'utf8');
}
