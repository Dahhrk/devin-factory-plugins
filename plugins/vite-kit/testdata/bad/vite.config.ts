import { defineConfig, loadEnv } from 'vite'

// Intentional smells for vite-rg-gate (not product code).
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return {
    define: { __ALL__: JSON.stringify(env) },
    server: {
      fs: {
        strict: false,
        allow: ['..'],
      },
    },
  }
})
