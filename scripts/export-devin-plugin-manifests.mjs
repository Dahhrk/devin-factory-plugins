#!/usr/bin/env node
// Regenerate missing plugins/*/.devin-plugin/plugin.json from sibling .cursor-plugin.
// Does not overwrite existing Devin manifests.
// Run: node scripts/export-devin-plugin-manifests.mjs [--assert]
// --assert: after create/skip, fail if any plugins/<kit> lacks .devin-plugin/plugin.json
import { readdirSync, readFileSync, existsSync, mkdirSync, writeFileSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const pluginsDir = join(root, "plugins");

const ASSERT = process.argv.includes("--assert");

const EXTRA = {
  ada: ["ada", "gnat", "gnatcheck"],
  "apps-script": ["apps-script", "clasp", "google"],
  assembly: ["assembly", "nasm", "gas"],
  astro: ["astro", "ssr"],
  batchfile: ["batch", "cmd", "windows"],
  c: ["c", "clang", "sanitizer"],
  cmake: ["cmake", "build"],
  cobol: ["cobol", "cobc"],
  cpp: ["cpp", "cplusplus", "clang-tidy"],
  csharp: ["csharp", "dotnet"],
  css: ["css", "styles"],
  delphi: ["delphi", "pascal"],
  dockerfile: ["dockerfile", "docker", "container"],
  elixir: ["elixir", "otp"],
  fortran: ["fortran", "gfortran"],
  go: ["go", "golang"],
  gotemplate: ["go", "templates", "helm"],
  html: ["html", "a11y"],
  java: ["java", "jvm"],
  javascript: ["javascript", "js", "node"],
  just: ["just", "justfile"],
  kotlin: ["kotlin", "jvm"],
  lexyacc: ["lex", "yacc", "bison"],
  makefile: ["make", "makefile"],
  mako: ["mako", "templates"],
  mdx: ["mdx", "markdown"],
  nix: ["nix", "nixos"],
  objc: ["objc", "objective-c", "apple"],
  php: ["php"],
  powershell: ["powershell", "pwsh"],
  pug: ["pug", "templates"],
  python: ["python", "ruff", "mypy"],
  r: ["r", "cran"],
  react: ["react", "jsx"],
  ruby: ["ruby", "rubocop"],
  rust: ["rust", "cargo", "clippy"],
  scss: ["scss", "sass"],
  shell: ["shell", "bash", "shellcheck"],
  slint: ["slint", "ui"],
  sql: ["sql", "database"],
  swift: ["swift", "apple"],
  tailwind: ["tailwind", "css"],
  typescript: ["typescript", "ts"],
  vbnet: ["vbnet", "dotnet"],
  vite: ["vite", "bundler"],
  wasm: ["wasm", "webassembly"],
  zig: ["zig"],
};

function stemOf(name) {
  return name.endsWith("-kit") ? name.slice(0, -4) : name;
}

function buildKeywords(name) {
  const stem = stemOf(name);
  const seen = new Set();
  const out = [];
  for (const k of ["devin", "plugin", stem, "poteto", "psr", ...(EXTRA[stem] || [])]) {
    if (!seen.has(k)) {
      seen.add(k);
      out.push(k);
    }
  }
  return out;
}

function toDevinDescription(cursorDesc, name) {
  let d = (cursorDesc || "").trim();
  if (!d) d = `${name} poteto bar packaged for the Devin coding lane.`;
  if (!/Twin of plug-factory/i.test(d)) {
    d = d.replace(/\.\s*$/, "") + `. Twin of plug-factory ${name}.`;
  }
  if (!/Devin/i.test(d)) {
    d = d.replace(/\.\s*$/, "") + ". Packaged for the Devin coding lane.";
  }
  return d;
}

let created = 0;
let skipped = 0;
const createdNames = [];

for (const entry of readdirSync(pluginsDir)) {
  const dir = join(pluginsDir, entry);
  if (!statSync(dir).isDirectory()) continue;
  const devinPath = join(dir, ".devin-plugin", "plugin.json");
  const cursorPath = join(dir, ".cursor-plugin", "plugin.json");
  if (existsSync(devinPath)) {
    skipped++;
    continue;
  }
  if (!existsSync(cursorPath)) {
    console.error("SKIP (no cursor, no devin):", entry);
    continue;
  }
  const cursor = JSON.parse(readFileSync(cursorPath, "utf8"));
  const manifest = {
    name: entry,
    version: cursor.version || "0.1.0",
    description: toDevinDescription(cursor.description, entry),
    author: { name: "Dark factory" },
    license: "MIT",
    keywords: buildKeywords(entry),
  };
  mkdirSync(join(dir, ".devin-plugin"), { recursive: true });
  writeFileSync(devinPath, JSON.stringify(manifest, null, 2) + "\n", "utf8");
  created++;
  createdNames.push(entry);
}

console.log(`export-devin-plugin-manifests: created=${created} skipped-existing=${skipped}`);
if (createdNames.length) console.log(createdNames.join("\n"));
if (ASSERT) {
  const missing = [];
  for (const entry of readdirSync(pluginsDir)) {
    const dir = join(pluginsDir, entry);
    if (!statSync(dir).isDirectory()) continue;
    const devinPath = join(dir, ".devin-plugin", "plugin.json");
    if (!existsSync(devinPath)) missing.push(entry);
  }
  if (missing.length) {
    console.error(
      "export-devin-plugin-manifests --assert FAILED: missing .devin-plugin/plugin.json for:",
    );
    for (const name of missing) console.error("  " + name);
    process.exit(1);
  }
  console.log("export-devin-plugin-manifests --assert: all kits have .devin-plugin/plugin.json");
}
