/**
 * Named JSON / wire parse boundary template.
 * Move bare JSON.parse behind a function; mark the parse line with ts-rg-allow.
 */
export function parseJsonUnknown(text: string): unknown {
  return JSON.parse(text) // ts-rg-allow named JSON boundary
}

export function parseJsonObject(text: string): Record<string, unknown> {
  const value = parseJsonUnknown(text)
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('expected JSON object')
  }
  return value as Record<string, unknown>
}
