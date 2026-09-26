import { defineConfig, loadEnv } from 'vite'

export default defineConfig(({ mode }) => {
  // Default prefix filter (VITE_); do not pass '' as third arg.
  const env = loadEnv(mode, process.cwd())
  return {
    define: {
      __APP_ENV__: JSON.stringify(env.VITE_APP_ENV ?? ''),
    },
  }
})
