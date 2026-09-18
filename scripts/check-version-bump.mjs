#!/usr/bin/env node
// CI guard: a PR that changes a plugin's content must also change that
// plugin's version. Escape hatch: the `no-bump` PR label (docs-only or
// repo-mechanics changes where a release bump is noise).
// Works in both layouts: plugins/<name>/.devin-plugin/plugin.json and
// <name>/.cursor-plugin/plugin.json. Zero deps.
import { execSync } from 'node:child_process';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';

const BASE = process.env.BASE_REF || 'origin/main';
const MANIFEST_DIR = /^\.(devin|cursor)-plugin$/;

const run = (cmd) => execSync(cmd, { encoding: 'utf8' }).trim();

const noBump = (() => {
  try {
    const event = JSON.parse(readFileSync(process.env.GITHUB_EVENT_PATH, 'utf8'));
    return (event.pull_request?.labels || []).some((l) => l.name === 'no-bump');
  } catch {
    return false;
  }
})();

// Discover plugin roots: every dir containing .{devin,cursor}-plugin/plugin.json.
const roots = [];
const walk = (dir, depth) => {
  if (depth > 3) return;
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (!e.isDirectory() || e.name === 'node_modules' || e.name.startsWith('.git')) continue;
    const p = join(dir, e.name);
    if (MANIFEST_DIR.test(e.name) && existsSync(join(p, 'plugin.json'))) {
      roots.push(dirname(p));
      continue;
    }
    walk(p, depth + 1);
  }
};
walk('.', 0);

const changed = run(`git diff --name-only ${BASE}...HEAD`).split('\n').filter(Boolean);

const versionAt = (ref, path) => {
  try {
    const out = execSync(`git show ${ref}:${path.replace(/\\/g, '/')}`, {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    });
    return JSON.parse(out).version;
  } catch {
    return undefined;
  }
};

const failures = [];
for (const root of roots) {
  const rel = root.replace(/\\/g, '/');
  const manifestPath = ['.devin-plugin', '.cursor-plugin']
    .map((d) => join(root, d, 'plugin.json'))
    .find(existsSync);
  const relManifest = manifestPath.replace(/\\/g, '/');
  const touched = changed.filter((f) => f.startsWith(rel + '/') && f !== relManifest);
  if (!touched.length) continue;
  const base = versionAt(BASE, manifestPath);
  if (base === undefined) continue; // new plugin: initial version is the bump
  const head = versionAt('HEAD', manifestPath);
  if (head === base) {
    failures.push(`${rel}: ${touched.length} content file(s) changed but version stays ${head}`);
  }
}

if (failures.length && noBump) {
  console.log(`version-bump: ${failures.length} plugin(s) unbumped - allowed by no-bump label`);
  process.exit(0);
}
if (failures.length) {
  console.error('version-bump: content changed without a version bump. Bump the plugin version or label the PR no-bump.');
  failures.forEach((f) => console.error(`  ${f}`));
  process.exit(1);
}
console.log(`version-bump: ok (${roots.length} plugin roots checked)`);
