import { defineConfig, loadEnv, searchForWorkspaceRoot } from 'vite'

export default defineConfig(({ mode }) => {
  // Prefer VITE_ prefix (default) — do not pass empty third arg.
  const env = loadEnv(mode, process.cwd())
  return {
    define: {
      __APP_ENV__: JSON.stringify(env.VITE_APP_ENV ?? ''),
    },
    server: {
      fs: {
        strict: true,
        allow: [searchForWorkspaceRoot(process.cwd())],
      },
    },
  }
})

// Documented intentional seam; allow on the smell line.
// const _demo = loadEnv('x', '.', '') // vite-rg-allow: fixture documents allow marker for intentional empty-prefix seam
const _demoAllow = "loadEnv(mode, dir, '')" // vite-rg-allow: fixture documents allow marker text for empty-prefix seam
void _demoAllow
