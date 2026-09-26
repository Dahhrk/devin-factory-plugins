/**
 * Named env boundary template (copy into product src/server/env.ts or similar).
 * Prefer a schema lib (zod / valibot / arktype) when the product already has one.
 * Whole-object `process.env` into the parser is allowed; bare `process.env.X`
 * accessors elsewhere still need `ts-rg-allow` on a named helper.
 */
export type AppEnv = {
  NODE_ENV: 'development' | 'test' | 'production'
  PORT: number
  DATABASE_URL?: string
}

type EnvMap = Record<string, string | undefined>

function requireString(raw: string | undefined, key: string): string {
  if (raw === undefined || raw === '') throw new Error(`missing env ${key}`)
  return raw
}

export function parseEnv(raw: EnvMap = process.env): AppEnv {
  const nodeEnv = raw.NODE_ENV ?? 'development'
  if (nodeEnv !== 'development' && nodeEnv !== 'test' && nodeEnv !== 'production') {
    throw new Error('invalid NODE_ENV')
  }
  const portRaw = raw.PORT
  const PORT = portRaw === undefined || portRaw === '' ? 3000 : Number(portRaw)
  if (!Number.isFinite(PORT)) throw new Error('invalid PORT')
  const DATABASE_URL = raw.DATABASE_URL
  return {
    NODE_ENV: nodeEnv,
    PORT,
    ...(DATABASE_URL !== undefined && DATABASE_URL !== ''
      ? { DATABASE_URL: requireString(DATABASE_URL, 'DATABASE_URL') }
      : {}),
  }
}

export const env = parseEnv()
