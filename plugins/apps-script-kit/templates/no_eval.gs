/**
 * Named boundary: ban string-eval and Function ctor call sites (PSR Apps Script).
 * Prefer parsers and typed data over dynamic code surfaces.
 * SPDX-License-Identifier: MIT
 */
function parsePayload_(raw) {
  const data = JSON.parse(raw);
  return data;
}
