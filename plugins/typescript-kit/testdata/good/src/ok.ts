export type Id = string

export function parseConfig(text: string): unknown {
  return JSON.parse(text) // ts-rg-allow named boundary
}

export function rootEl(): Element {
  const el = document.getElementById('root')
  if (!el) throw new Error('missing root')
  return el
}

// @ts-expect-error - intentional fixture for described expect-error
export const described = true

export function narrow(x: unknown): x is Id {
  return typeof x === 'string'
}

export type Ev = { type: "a"; n: number } | { type: "b"; s: string }

function assertNever(x: never): never {
  throw new Error(String(x))
}

export function handle(ev: Ev): string {
  switch (ev.type) {
    case "a":
      return String(ev.n)
    case "b":
      return ev.s
    default:
      return assertNever(ev)
  }
}

export async function loadJson(url: string): Promise<unknown> {
  const res = await fetch(url) // ts-rg-allow named fetch boundary
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

export function parseHref(href: string): URL {
  return new URL(href) // ts-rg-allow named URL boundary
}

export function readPort(fallback = 3000): number {
  const raw = process.env.PORT // ts-rg-allow named env boundary
  if (raw === undefined || raw === '') return fallback
  const n = Number(raw)
  if (!Number.isFinite(n)) throw new Error('invalid PORT')
  return n
}

type Prefetchable = { fetch: () => Promise<void> }
export async function prefetchAll(q: Prefetchable): Promise<void> {
  await q.fetch()
}

export function parseAppEnv(raw: Record<string, string | undefined> = process.env): { port: number } {
  const portRaw = raw.PORT
  const port = portRaw === undefined || portRaw === '' ? 3000 : Number(portRaw)
  if (!Number.isFinite(port)) throw new Error('invalid PORT')
  return { port }
}
