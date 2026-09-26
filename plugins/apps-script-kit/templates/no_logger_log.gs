/**
 * Named boundary: no Logger.log in library modules (PSR Apps Script).
 * Prefer return values; callers decide how to surface errors.
 * SPDX-License-Identifier: MIT
 */
function summarizeRows_(rows) {
  return { count: rows.length };
}
