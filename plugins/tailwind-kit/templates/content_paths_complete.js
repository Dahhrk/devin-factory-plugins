/** @type {import('tailwindcss').Config} */
// Named boundary: content / @source must cover every template that emits classes.
// Anti-pattern (banned without allow): content: []
module.exports = {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx,vue,svelte,astro}'],
  theme: { extend: {} },
  plugins: [],
}
