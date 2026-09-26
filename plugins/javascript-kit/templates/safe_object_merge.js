/* Named boundary: merge untrusted input into a null-prototype object.
 * Avoid Object.assign onto shared prototypes / __proto__ keys.
 * Copy into product sources; keep js-rg-allow only on intentional seams.
 */
/**
 * @param {Record<string, unknown>} target
 * @param {Record<string, unknown>} source
 * @returns {Record<string, unknown>}
 */
export function mergeOwn(target, source) {
  const out = Object.assign(Object.create(null), target);
  for (const key of Object.keys(source)) {
    if (key === '__proto__' || key === 'constructor' || key === 'prototype') continue;
    out[key] = source[key];
  }
  return out;
}
