#!/usr/bin/env node
// Self-update for machines where `devin plugins update` is unavailable
// (non-enterprise plans) or the app's managed refresh fails.
// Syncs a local clone of devin-factory-plugins into the Devin plugin cache.
// Silent and fail-open by design — a SessionStart hook must never break a session.
import { execSync } from "node:child_process";
import { cpSync, existsSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const repo = process.env.DEVIN_FACTORY_REPO || join(homedir(), "Projects", "devin-factory-plugins");
const pluginsDir = join(homedir(), "AppData", "Roaming", "devin", "cli", "plugins");
const cacheRoot = join(pluginsDir, "cache");
const lockPath = join(pluginsDir, "lock.json");

const manifestOf = (dir) => [join(dir, ".devin-plugin", "plugin.json"), join(dir, "plugin.json")].find(existsSync);
if (!manifestOf(repo) || !existsSync(cacheRoot)) process.exit(0);

try {
	execSync("git pull --ff-only", { cwd: repo, stdio: "ignore", timeout: 15000 });
} catch {}

// Keep sibling factory clones fresh too - working trees that stay
// ff-only clean pull silently; dirty or diverged clones are skipped.
const siblings = [
	["PLUG_FACTORY_REPO", "plug-factory"],
	["DARK_FACTORY_REPO", "dark-factory"],
	["OPEN_BOT_REPO", "open-bot"],
];
for (const [env, dir] of siblings) {
	const path = process.env[env] || join(homedir(), "Projects", dir);
	try {
		execSync("git pull --ff-only", { cwd: path, stdio: "ignore", timeout: 15000 });
	} catch {}
}
const sha = execSync("git rev-parse HEAD", { cwd: repo, encoding: "utf8" }).trim();

const versionOf = (dir) => JSON.parse(readFileSync(manifestOf(dir), "utf8")).version;

const cacheDirs = readdirSync(cacheRoot).filter((d) => d.startsWith("github.com_Dahhrk_devin-factory-plugins"));
const rootDir = (d) => !d.includes("_plugins_");
const pluginDir = (name) => (d) => d.startsWith(`github.com_Dahhrk_devin-factory-plugins_plugins_${name}`);

const mirror = (srcDir, match) => {
	const version = versionOf(srcDir);
	for (const id of cacheDirs.filter(match)) {
		const dest = join(cacheRoot, id, version);
		rmSync(dest, { recursive: true, force: true });
		cpSync(srcDir, dest, { recursive: true });
	}
	return version;
};

const versions = {};
versions["dark-factory-pack"] = mirror(repo, rootDir);
for (const name of readdirSync(join(repo, "plugins"))) {
	const dir = join(repo, "plugins", name);
	if (!existsSync(join(dir, ".devin-plugin"))) continue;
	versions[name] = mirror(dir, pluginDir(name));
}

if (existsSync(lockPath)) {
	const lock = JSON.parse(readFileSync(lockPath, "utf8"));
	for (const entry of lock.resolved || []) {
		if (versions[entry.name]) {
			entry.version_dir = versions[entry.name];
			entry.resolved.sha = sha;
			entry.fetched_at = { secs_since_epoch: Math.floor(Date.now() / 1000), nanos_since_epoch: 0 };
			delete entry.refresh_failure;
		}
	}
	writeFileSync(lockPath, JSON.stringify(lock, null, 2));
}
