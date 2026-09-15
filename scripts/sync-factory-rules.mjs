#!/usr/bin/env node
import { execSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync, unlinkSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const srcDir = join(root, 'plugins', 'factory-baseline', 'rules');

const LANE_SPECIFIC = new Set(['factory-os', 'close-loop']);

let sha = 'worktree';
try {
  sha = execSync('git rev-parse --short HEAD', { cwd: root, encoding: 'utf8' }).trim();
} catch {}

const targets = [
  {
    dir: join(homedir(), '.cursor', 'rules'),
    name: (rule) => `${rule}.mdc`,
    wrap: (rule, body, marker) =>
      `---\ndescription: factory-baseline ${rule}\nalwaysApply: true\n---\n\n${marker}\n\n${body}`,
  },
  {
    dir: join(homedir(), '.devin', 'rules'),
    name: (rule) => `${rule}.md`,
    wrap: (rule, body, marker) => `${marker}\n\n${body}`,
  },
];

const sources = readdirSync(srcDir)
  .filter((f) => f.endsWith('.md'))
  .map((f) => basename(f, '.md'))
  .filter((rule) => !LANE_SPECIFIC.has(rule));

let wrote = 0;
let unchanged = 0;
let removed = 0;

for (const target of targets) {
  if (!existsSync(target.dir)) mkdirSync(target.dir, { recursive: true });
  const synced = new Set();
  for (const rule of sources) {
    const body = readFileSync(join(srcDir, `${rule}.md`), 'utf8').trim();
    const marker = `<!-- synced from devin-factory-plugins@${sha} rules/${rule}.md - edit there, then run scripts/sync-factory-rules.mjs -->`;
    const dest = join(target.dir, target.name(rule));
    const content = `${target.wrap(rule, body, marker)}\n`;
    synced.add(basename(dest));
    if (existsSync(dest) && readFileSync(dest, 'utf8') === content) {
      unchanged++;
    } else {
      writeFileSync(dest, content);
      wrote++;
    }
  }
  for (const f of readdirSync(target.dir)) {
    const p = join(target.dir, f);
    if (synced.has(f)) continue;
    if (!existsSync(p) || !readFileSync(p, 'utf8').includes('synced from devin-factory-plugins')) continue;
    unlinkSync(p);
    removed++;
  }
}

console.log(`sync-factory-rules: ${wrote} written, ${unchanged} unchanged, ${removed} stale removed`);
console.log(`rules: ${sources.join(', ')} (lane-specific skipped: ${[...LANE_SPECIFIC].join(', ')})`);

// Lane-specific rules are hand-ported (Devin and Cursor editions differ on
// purpose). Drift guard: each ported .mdc carries a
// `ported from devin-factory-plugins@<sha>` marker; warn when the plugin
// source moved past it so the port gets refreshed instead of silently
// diverging.
const CURSOR_PORT_MAP = {
  'factory-os': { src: 'plugins/factory-baseline/rules/factory-os.md', dest: 'poteto-factory-os.mdc' },
  'close-loop': { src: 'plugins/factory-baseline/rules/close-loop.md', dest: 'close-loop.mdc' },
  'pstack-models': { src: 'plugins/pstack/rules/pstack-models.md', dest: 'pstack-models.mdc' },
};
const cursorRulesDir = join(homedir(), '.cursor', 'rules');
for (const [rule, { src, dest: destName }] of Object.entries(CURSOR_PORT_MAP)) {
  let srcSha = '';
  try {
    srcSha = execSync(`git log -1 --format=%h -- "${src}"`, { cwd: root, encoding: 'utf8' }).trim();
  } catch {}
  const dest = join(cursorRulesDir, destName);
  if (!existsSync(dest)) {
    console.log(`drift: ${destName} missing - port ${src} to Cursor`);
    continue;
  }
  const marker = readFileSync(dest, 'utf8').match(/ported from devin-factory-plugins@([0-9a-f]+)/);
  if (!srcSha) continue;
  if (!marker) {
    console.log(`drift: ${destName} has no port marker - add <!-- ported from devin-factory-plugins@${srcSha} ${src} --> after next port`);
  } else if (marker[1] !== srcSha && !srcSha.startsWith(marker[1])) {
    console.log(`drift: ${destName} ported from ${marker[1]} but ${src} is at ${srcSha} - re-port`);
  }
}
