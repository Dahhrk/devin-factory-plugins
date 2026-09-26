/** @type {import('tailwindcss').Config} */
// Named boundary: prefer correct content paths over safelist / @source inline.
// Anti-pattern (banned without allow): safelist: [{ pattern: /.*/ }]
module.exports = {
  content: ['./src/**/*.{html,js,ts,jsx,tsx}'],
  theme: { extend: {} },
  plugins: [],
}
