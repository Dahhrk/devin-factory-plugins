#!/usr/bin/env node
// Validates the structure of every plugin under plugins/.
// Run: node scripts/validate-plugins.mjs

import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const pluginsDir = join(root, "plugins");

const errors = [];
const kebab = /^[a-z0-9]+(-[a-z0-9]+)*$/;

function fail(msg) {
  errors.push(msg);
}

function parseJson(path, label) {
  try {
    return JSON.parse(readFileSync(path, "utf8"));
  } catch (e) {
    fail(`${label}: invalid JSON (${e.message})`);
    return null;
  }
}

function frontmatter(path) {
  const text = readFileSync(path, "utf8");
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) return null;
  const fields = {};
  for (const line of m[1].split(/\r?\n/)) {
    const idx = line.indexOf(":");
    if (idx > 0) fields[line.slice(0, idx).trim()] = line.slice(idx + 1).trim();
  }
  return fields;
}

function checkSkillLike(dir, kind) {
  if (!existsSync(dir)) return;
  for (const entry of readdirSync(dir)) {
    if (!statSync(join(dir, entry)).isDirectory()) continue;
    const md = join(dir, entry, `${kind === "skill" ? "SKILL" : "AGENT"}.md`);
    const label = md.slice(root.length + 1);
    if (!existsSync(md)) {
      fail(`${label}: missing ${kind === "skill" ? "SKILL" : "AGENT"}.md in ${entry}/`);
      continue;
    }
    const fm = frontmatter(md);
    if (!fm) fail(`${label}: missing YAML frontmatter`);
    else {
      if (!fm.name) fail(`${label}: frontmatter missing "name"`);
      if (!fm.description) fail(`${label}: frontmatter missing "description"`);
      if (fm.name && fm.name !== entry)
        fail(`${label}: frontmatter name "${fm.name}" should match directory "${entry}"`);
    }
  }
}

if (!existsSync(pluginsDir)) {
  fail("plugins/ directory not found");
} else {
  const names = new Set();
  for (const entry of readdirSync(pluginsDir)) {
    const dir = join(pluginsDir, entry);
    if (!statSync(dir).isDirectory()) continue;

    const manifestPath = join(dir, ".devin-plugin", "plugin.json");
    const label = `plugins/${entry}`;
    if (!existsSync(manifestPath)) {
      fail(`${label}: missing .devin-plugin/plugin.json`);
      continue;
    }
    const manifest = parseJson(manifestPath, `${label}/.devin-plugin/plugin.json`);
    if (!manifest) continue;

    if (!manifest.name) fail(`${label}: manifest missing "name"`);
    else {
      if (!kebab.test(manifest.name))
        fail(`${label}: name "${manifest.name}" must be lowercase kebab-case`);
      if (names.has(manifest.name)) fail(`${label}: duplicate plugin name "${manifest.name}"`);
      names.add(manifest.name);
      if (manifest.name !== entry)
        fail(`${label}: manifest name "${manifest.name}" should match directory "${entry}"`);
    }
    if (manifest.version && !/^\d+\.\d+\.\d+([-+].*)?$/.test(manifest.version))
      fail(`${label}: version "${manifest.version}" is not semver`);
    for (const list of ["requiredPlugins", "optionalPlugins", "forbiddenPlugins"]) {
      if (manifest[list] !== undefined && !Array.isArray(manifest[list]))
        fail(`${label}: "${list}" must be an array`);
    }
    // Same-repo git-subdir references must point at real sibling plugins.
    for (const list of ["requiredPlugins", "optionalPlugins"]) {
      for (const ref of Array.isArray(manifest[list]) ? manifest[list] : []) {
        if (
          typeof ref === "object" &&
          ref !== null &&
          ref.source === "git-subdir" &&
          typeof ref.url === "string" &&
          /\/devin-factory-plugins(\.git)?$/.test(ref.url) &&
          typeof ref.path === "string"
        ) {
          const target = join(root, ref.path, ".devin-plugin", "plugin.json");
          if (!existsSync(target))
            fail(`${label}: ${list} entry "${ref.path}" does not resolve to a plugin in this repo`);
        }
      }
    }

    checkSkillLike(join(dir, "skills"), "skill");
    checkSkillLike(join(dir, "agents"), "agent");

    for (const file of ["hooks.json", "mcp_config.json"]) {
      const p = join(dir, file);
      if (existsSync(p)) parseJson(p, `${label}/${file}`);
    }
  }
  if (names.size === 0) fail("no plugins found under plugins/");
}

if (errors.length) {
  console.error(`Validation failed with ${errors.length} error(s):`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log("Plugin validation passed.");
