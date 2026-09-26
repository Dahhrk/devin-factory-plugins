export const a = 1 as any
export const b: any = 1
export type T = Array<any>
export type U = any[]
export type P = Promise<any>
export type R = Record<string, any>
// @ts-ignore
// @ts-nocheck
export const d = 1 as unknown as string
// @ts-expect-error
export const el = document.getElementById('x')!
export const q = document.querySelector('.x')!
export const raw = JSON.parse('{}')
