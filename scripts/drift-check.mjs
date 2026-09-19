#!/usr/bin/env node
// Cross-factory drift check: compares a pack in this repo against its twin
// in the other factory, normalizing platform-format differences.
//
//   node scripts/drift-check.mjs [other-repo-path]
//
// Default other-repo: $PLUG_FACTORY_REPO or ~/Projects/plug-factory when run
// from devin-factory-plugins, $DEVIN_FACTORY_REPO or
// ~/Projects/devin-factory-plugins when run from plug-factory.
//
// FAIL: file/dir missing in either direction (after normalization), a
// section header present on one side and absent on the other with no close
// match, or a numbered rule id missing on one side.
// WARN: a header that looks renamed (high token overlap) — review by hand.
// Zero deps.

import { execSync } from 'node:child_process';
import { existsSync, readdirSync, readFileSync, statSync } from 'node:fs';
import { homedir } from 'node:os';
import { basename, join, relative } from 'node:path';

const here = process.cwd();
const isDevinRepo = existsSync(join(here, 'plugins', 'pstack')) && existsSync(join(here, 'plugins', 'factory-baseline'));
const PACKS = isDevinRepo
  ? [['plugins/pstack', 'pstack'], ['plugins/cursor-team-kit', 'cursor-team-kit']]
  : [['pstack', 'pstack'], ['cursor-team-kit', 'cursor-team-kit']];

const other = process.argv[2]
  || process.env[isDevinRepo ? 'PLUG_FACTORY_REPO' : 'DEVIN_FACTORY_REPO']
  || join(homedir(), 'Projects', isDevinRepo ? 'plug-factory' : 'devin-factory-plugins');

const otherRoot = (packDir) => {
  // other side: devin keeps packs under plugins/, normal keeps them at root
  const direct = join(other, packDir);
  if (existsSync(direct)) return direct;
  const underPlugins = join(other, 'plugins', basename(packDir));
  if (existsSync(underPlugins)) return underPlugins;
  return join(other, basename(packDir));
};

if (!existsSync(other)) {
  console.error(`drift-check: other repo not found at ${other}`);
  process.exit(2);
}

// Paired-PR tolerance: a file missing on one side is a warning, not a
// failure, when an open PR on that side's GitHub repo already carries it.
// Mirrored changes land on two mains at different times; the gate should
// not deadlock them. Set DRIFT_NO_PR_LOOKUP=1 to disable.
const pendingByRepo = (repoDir) => {
  const pending = new Map(); // "<pack>/<normRel>" -> PR number
  if (process.env.DRIFT_NO_PR_LOOKUP) return pending;
  try {
    const url = execSync('git remote get-url origin', { cwd: repoDir, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
    const m = url.match(/github\.com[:/]([^/]+\/[^/.]+)/);
    if (!m) return pending;
    const slug = m[1];
    const gh = (args) => execSync(`gh ${args}`, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
    const prs = JSON.parse(gh(`pr list --repo ${slug} --state open --limit 50 --json number`));
    for (const { number } of prs) {
      const files = JSON.parse(gh(`pr view ${number} --repo ${slug} --json files`)).files || [];
      for (const { path } of files) {
        const p = path.replace(/^plugins\//, '');
        for (const [, packName] of PACKS) {
          if (p.startsWith(`${packName}/`)) {
            pending.set(`${packName}/${normRel(p.slice(packName.length + 1))}`, number);
          }
        }
      }
    }
  } catch { /* no gh, no remote, or private peer - strict mode */ }
  return pending;
};

// Files/dirs that legitimately exist on only one side.
const EXPECTED_DEVIN_ONLY = new Set([
  'rules/pstack-models.md',          // Devin role->profile map
  'agents/panelist-claude',
  'agents/panelist-gpt',
  'agents/panelist-swe',
  'agents/panelist-gemini',
]);
const EXPECTED_NORMAL_ONLY = new Set(['.gitignore']);

// Canonical key for a relative path across the two formats.
const normRel = (rel) => rel
  .replace(/\\/g, '/')
  .replace(/\.(devin|cursor)-plugin\/plugin\.json$/, 'plugin.json') // manifest twin
  .replace(/\.mdc$/, '.md')                          // cursor rule ext
  .replace(/agents\/([^/]+)\/AGENT\.md$/, 'agents/$1') // devin agent dir
  .replace(/agents\/([^/]+)\.md$/, 'agents/$1');       // cursor agent file

// List [{norm, real, isDir}] under <root>/<sub>.
const listTree = (root, sub) => {
  const base = join(root, sub);
  if (!existsSync(base)) return [];
  const out = [];
  const walk = (dir) => {
    for (const e of readdirSync(dir, { withFileTypes: true })) {
      const p = join(dir, e.name);
      const rel = relative(base, p).replace(/\\/g, '/');
      if (e.isDirectory()) {
        if (e.name === 'node_modules' || e.name.startsWith('.git')) continue;
        walk(p);
        continue;
      }
      out.push({ norm: normRel(rel), real: p, isDir: false });
    }
  };
  walk(base);
  return out;
};

// Resolve the readable markdown file for a normalized entry.
const readablePath = (root, packDir, norm) => {
  const direct = join(root, packDir, norm);
  if (existsSync(direct) && statSync(direct).isFile()) return direct;
  // normalized .mdc -> .md on the other side
  const mdc = direct.replace(/\.md$/, '.mdc');
  if (existsSync(mdc)) return mdc;
  // normalized agents/<n> -> dir containing AGENT.md or <n>.md
  if (existsSync(direct) && statSync(direct).isDirectory()) {
    const agent = join(direct, 'AGENT.md');
    if (existsSync(agent)) return agent;
  }
  const file = direct + '.md';
  if (existsSync(file)) return file;
  return null;
};

const readLines = (path) => {
  try { return readFileSync(path, 'utf8').split('\n'); } catch { return []; }
};

const headersOf = (path) => readLines(path)
  .map((l) => l.match(/^(#{1,4})\s+(.*)/))
  .filter(Boolean)
  .map((m) => m[2].trim());

const ruleIdsOf = (path) => readLines(path)
  .map((l) => l.match(/^(\d{1,2})\.\s/))
  .filter(Boolean)
  .map((m) => m[1]);

const tokenOverlap = (a, b) => {
  const ta = new Set(a.toLowerCase().split(/\W+/).filter((t) => t.length > 2));
  const tb = new Set(b.toLowerCase().split(/\W+/).filter((t) => t.length > 2));
  if (!ta.size || !tb.size) return 0;
  let hit = 0;
  for (const t of ta) if (tb.has(t)) hit++;
  return hit / Math.max(ta.size, tb.size);
};

const fails = [];
const warns = [];

for (const [packDir, packName] of PACKS) {
  const b = otherRoot(packDir);
  if (!existsSync(join(here, packDir))) { fails.push(`${packName}: missing locally (${packDir})`); continue; }
  if (!existsSync(b)) { fails.push(`${packName}: missing in other repo (${b})`); continue; }

  const mine = new Map(listTree(here, packDir).map((e) => [e.norm, e]));
  const theirs = new Map(listTree(b, '.').map((e) => [e.norm, e]));

  const expectedHere = isDevinRepo ? EXPECTED_DEVIN_ONLY : EXPECTED_NORMAL_ONLY;
  const expectedThere = isDevinRepo ? EXPECTED_NORMAL_ONLY : EXPECTED_DEVIN_ONLY;
  const pendingHere = pendingByRepo(here);
  const pendingThere = pendingByRepo(other);
  for (const f of mine.keys()) {
    if (theirs.has(f) || expectedHere.has(f)) continue;
    const pr = pendingThere.get(`${packName}/${f}`);
    if (pr) warns.push(`${packName}: only here -> ${f} (carried by other repo PR #${pr})`);
    else fails.push(`${packName}: only here -> ${f}`);
  }
  for (const f of theirs.keys()) {
    if (mine.has(f) || expectedThere.has(f)) continue;
    const pr = pendingHere.get(`${packName}/${f}`);
    if (pr) warns.push(`${packName}: only in other -> ${f} (carried by this repo PR #${pr})`);
    else fails.push(`${packName}: only in other -> ${f}`);
  }

  // Content checks on shared markdown: section headers and numbered rule ids.
  // Scoped to shared content: skills, rules, docs, references, playbooks.
  // READMEs and agent files are platform docs — intentional divergence.
  const isSharedContent = (f) =>
    /^(skills|rules|docs|automations)\//.test(f) && /\.md$/.test(f) && basename(f) !== 'README.md';

  for (const f of mine.keys()) {
    if (!theirs.has(f) || !isSharedContent(f)) continue;
    const pa = readablePath(here, packDir, f);
    const pb = readablePath(b, '.', f);
    if (!pa || !pb) continue;

    const ha = headersOf(pa), hb = headersOf(pb);
    const onlyA = ha.filter((h) => !hb.includes(h));
    const onlyB = hb.filter((h) => !ha.includes(h));
    for (const h of onlyA) {
      const near = onlyB.find((o) => tokenOverlap(h, o) >= 0.4 || (h.match(/^Step \d+/) && o.match(/^Step \d+/) && h[5] === o[5]));
      if (near) warns.push(`${packName}/${f}: header renamed? "${h}" vs "${near}"`);
      else fails.push(`${packName}/${f}: section only here -> "${h}"`);
    }
    for (const h of onlyB) {
      const near = onlyA.find((o) => tokenOverlap(h, o) >= 0.4 || (h.match(/^Step \d+/) && o.match(/^Step \d+/) && h[5] === o[5]));
      if (near) continue; // already warned from the other direction
      fails.push(`${packName}/${f}: section only in other -> "${h}"`);
    }

    const ra = ruleIdsOf(pa), rb = ruleIdsOf(pb);
    if (ra.length && rb.length) {
      const setA = new Set(ra), setB = new Set(rb);
      for (const id of setA) if (!setB.has(id)) fails.push(`${packName}/${f}: rule ${id} missing in other`);
      for (const id of setB) if (!setA.has(id)) fails.push(`${packName}/${f}: rule ${id} missing here`);
    }
  }
}

for (const w of warns) console.log(`warn: ${w}`);
if (fails.length) {
  console.error('drift-check: unexplained drift found');
  fails.forEach((f) => console.error(`  ${f}`));
  process.exit(1);
}
console.log(`drift-check: ok (${PACKS.length} packs compared, ${warns.length} rename warning(s))`);
