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
