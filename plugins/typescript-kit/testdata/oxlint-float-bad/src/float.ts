async function load(): Promise<string> {
  return 'ok'
}

export async function boot(): Promise<void> {
  await load()
}

// floating promises (must fail type-aware no-floating-promises)
load()
boot()

// misused promise: async callback where void return expected
function onReady(handler: () => void): void {
  handler()
}

onReady(async () => {
  await load()
})

// setTimeout(async) - repeating product smell (hop/excalidraw/cal)
setTimeout(async () => {
  await load()
}, 0)
