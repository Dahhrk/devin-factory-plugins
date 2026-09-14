#!/usr/bin/env node
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const root = process.argv[2] ?? ".";
const SKIP_DIRS = new Set([
  "node_modules", ".git", "dist", "build", ".next", ".vite", "vendor",
  "coverage", "out", "tmp", ".turbo", ".cache", "third_party", "external",
  "local",
]);
const SRC = /\.(m?[jt]sx?|c|cc|cpp|cxx|h|hh|hpp|hxx|lua|py|go|rs)$/;
const TEST_FILE = /(\.test\.|\.spec\.|__tests__|_test\.)/;

const CLASSES = [
  {
    name: "comment-lines",
    hit: /(^\s*(\/\/|\/\*|\*|--(?!\[\[))|<!--)/,
    why: "comments are findings unless license/API/forced-behavior",
  },
  {
    name: "todo-markers",
    hit: /\b(TODO|FIXME|HACK|XXX|WIP)\b/,
    why: "stale intent — resolve or delete",
  },
  {
    name: "debug-leftovers",
    hit: /\b(console\.log|debugger|pdb\.set_trace|print\s*\(|printf\s*\(|std::cout|std::cerr)/,
    why: "scratch output — delete or make it a real log",
  },
  {
    name: "anon-multi-statement",
    hit: /(=>|function\s*\()/,
    anon: /((:\s*|=\s*|\(|,)\s*(async\s*)?function\s*\(|=>\s*\{)/,
    why: "multi-statement anonymous blocks get named functions",
  },
];

const LOOP = /(\bfor\b|\bwhile\b|\.forEach\s*\(|\.map\s*\()/;

const files = [];
function walk(dir) {
  for (const entry of readdirSync(dir)) {
    if (SKIP_DIRS.has(entry)) continue;
    const p = join(dir, entry);
    const st = statSync(p);
    if (st.isDirectory()) walk(p);
    else if (SRC.test(entry)) files.push(p);
  }
}
walk(root);

const totals = {};
const hotspots = {};
for (const file of files) {
  let text;
  try {
    text = readFileSync(file, "utf8");
  } catch {
    continue;
  }
  const lines = text.split("\n");
  const rel = relative(root, file);

  const isTest = TEST_FILE.test(rel);
  for (const cls of CLASSES) {
    if (isTest && cls.anon) continue;
    let n = 0;
    for (const line of lines) {
      if (!cls.hit.test(line)) continue;
      if (cls.anon && !cls.anon.test(line)) continue;
      n++;
    }
    if (n) {
      totals[cls.name] = (totals[cls.name] ?? 0) + n;
      (hotspots[cls.name] ??= []).push([n, rel]);
    }
  }

  let loops = 0, awaits = 0, finds = 0;
  if (!isTest) for (const line of lines) {
    if (LOOP.test(line)) loops++;
    if (/\bawait\b/.test(line)) awaits++;
    if (/\.(find|filter|includes|indexOf)\s*\(/.test(line)) finds++;
  }
  if (loops && awaits > loops) {
    totals["await-in-loop?"] = (totals["await-in-loop?"] ?? 0) + 1;
    (hotspots["await-in-loop?"] ??= []).push([awaits, rel]);
  }
  if (loops && finds) {
    totals["linear-scan-in-loop?"] = (totals["linear-scan-in-loop?"] ?? 0) + 1;
    (hotspots["linear-scan-in-loop?"] ??= []).push([finds, rel]);
  }
}

console.log(`scanned ${files.length} source files under ${root}\n`);
const names = [...CLASSES.map((c) => c.name), "await-in-loop?", "linear-scan-in-loop?"];
for (const name of names) {
  if (!totals[name]) continue;
  console.log(`${name}: ${totals[name]}`);
  const top = (hotspots[name] ?? []).sort((a, b) => b[0] - a[0]).slice(0, 5);
  for (const [n, f] of top) console.log(`  ${n}\t${f}`);
}
console.log("\nheuristics flag candidates, not verdicts - read before deleting");
