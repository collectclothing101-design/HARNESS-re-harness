#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { access, mkdir, readFile, realpath, rm, writeFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import process from 'node:process';
import { compileRuntime, runtimeConfig } from './compiler.js';
import { TransactionalConfig } from './config.js';
import { validateManifest, type Runtime } from './model.js';
import { validateVersionAuthority } from './release.js';
import { VERSION } from './version.js';

const runtimes = ['claude','codex','chatgpt','mimo','opencode','hermes','frank','generic'] as const;
function option(args: string[], name: string): string | undefined { const index = args.indexOf(name); return index < 0 ? undefined : args[index + 1]; }
function fail(message: string): never { process.stderr.write(`${message}\n`); process.exit(1); }
async function load(path: string) { return validateManifest(JSON.parse(await readFile(resolve(path), 'utf8'))); }
async function emit(path: string, content: string, exclusive = false): Promise<void> { await mkdir(dirname(path), { recursive: true }); await writeFile(path, content, { flag: exclusive ? 'wx' : 'w' }); }
type GeneratedReceipt = { path: string; sha256: string };
type Receipt = { receiptVersion?: number; version: string; runtime: Runtime; root: string; config: string; configExisted?: boolean; backup: string; generated: Array<string | GeneratedReceipt>; installedAt: string };
const receiptPath = (root: string) => join(root, '.harness-re-harness/install.json');
async function receipt(root: string): Promise<Receipt> { return JSON.parse(await readFile(receiptPath(root), 'utf8')) as Receipt; }
function within(root: string, path: string): boolean { const value = relative(resolve(root), resolve(path)); return value !== '' && value !== '..' && !value.startsWith(`..${sep}`) && !isAbsolute(value); }
async function exists(path: string): Promise<boolean> { return access(path).then(() => true).catch(() => false); }
async function nearestExisting(path: string): Promise<string> {
  let candidate = resolve(path);
  while (!await exists(candidate)) {
    const parent = dirname(candidate);
    if (parent === candidate) throw new Error(`no existing ancestor for path: ${path}`);
    candidate = parent;
  }
  return realpath(candidate);
}
async function assertContained(root: string, path: string): Promise<void> {
  const [canonicalRoot, canonicalTarget] = await Promise.all([realpath(root), nearestExisting(path)]);
  if (canonicalTarget !== canonicalRoot && !within(canonicalRoot, canonicalTarget)) fail(`path escapes installation root through a symlink: ${path}`);
}
function sha256(value: string | Buffer): string { return createHash('sha256').update(value).digest('hex'); }
function generatedRecords(record: Receipt): Array<{ path: string; sha256?: string }> {
  return record.generated.map(value => typeof value === 'string' ? { path: value } : value);
}
async function currentHash(path: string): Promise<string | undefined> { return readFile(path).then(value => sha256(value)).catch(() => undefined); }

async function main(args: string[]): Promise<void> {
  const packageRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
  const command = args[0];
  if (!command || command === 'help' || args.includes('--help')) {
    process.stdout.write('harness-re-harness <validate|compile|install|verify|rollback|uninstall|doctor|version|version-check|serve> [options]\n'); return;
  }
  if (command === 'version') { process.stdout.write(`${VERSION.package}\n`); return; }
  if (command === 'serve') { const { runStdioServer } = await import('./server.js'); await runStdioServer(); return; }
  if (command === 'validate') {
    if (!args[1]) fail('validate requires a manifest path');
    const manifest = await load(args[1]);
    process.stdout.write(`${JSON.stringify({ valid: true, name: manifest.name, upstream: manifest.upstream.commit })}\n`); return;
  }
  if (command === 'compile') {
    if (!args[1]) fail('compile requires a manifest path');
    const selected = option(args, '--runtime');
    if (!selected || !runtimes.includes(selected as Runtime)) fail(`--runtime must be one of: ${runtimes.join(', ')}`);
    const out = resolve(option(args, '--out') ?? 'generated');
    const result = compileRuntime(await load(args[1]), selected as Runtime);
    for (const file of result.files) await emit(join(out, file.path), file.content);
    await emit(join(out, `${selected}.downgrades.json`), `${JSON.stringify(result.downgrades, null, 2)}\n`);
    process.stdout.write(`${JSON.stringify({ runtime: selected, out, files: result.files.map(x => x.path), downgrades: result.downgrades })}\n`); return;
  }
  if (command === 'install') {
    const global = args.includes('--global');
    if (global && !args.includes('--allow-global')) fail('global configuration mutation requires explicit --allow-global');
    if (args.includes('--replace')) fail('--replace is not supported until ownership-safe upgrades are implemented');
    if (!args[1] || args[1].startsWith('--')) fail('install requires a manifest path');
    const selected = option(args, '--runtime');
    if (!selected || !runtimes.includes(selected as Runtime)) fail(`--runtime must be one of: ${runtimes.join(', ')}`);
    const root = global ? homedir() : resolve(option(args, '--project') ?? '.');
    const runtime = selected as Runtime;
    const descriptor = runtimeConfig(runtime);
    const config = resolve(option(args, '--config') ?? join(root, descriptor.path));
    if (!within(root, config)) fail('configuration path must remain inside the installation root');
    await assertContained(root, config);
    if (await exists(receiptPath(root))) fail('installation receipt already exists; uninstall before reinstalling');
    if (await exists(`${config}.hrh-backup`)) fail('stale configuration backup exists; resolve it before installing');
    const compilation = compileRuntime(await load(args[1]), runtime);
    const targets = compilation.files
      .map(file => ({ file, target: resolve(root, file.path) }))
      .filter(({ target }) => target !== config);
    const seen = new Set<string>();
    for (const { target } of targets) {
      if (!within(root, target)) fail(`generated path escapes installation root: ${target}`);
      await assertContained(root, target);
      if (seen.has(target)) fail(`duplicate generated path: ${target}`);
      seen.add(target);
      if (await exists(target)) fail(`generated asset collision: ${target}`);
    }
    const configExisted = await exists(config);
    if (!configExisted) await emit(config, descriptor.format === 'json' || descriptor.format === 'jsonc' || descriptor.format === 'yaml' ? '{}\n' : '');
    const tx = new TransactionalConfig();
    let merged: { changed: boolean; backup: string } | undefined;
    const generated: GeneratedReceipt[] = [];
    try {
      merged = await tx.merge(config, descriptor.format, descriptor.patch);
      for (const { file, target } of targets) {
        await emit(target, file.content, true);
        generated.push({ path: target, sha256: sha256(file.content) });
      }
      const record: Receipt = { receiptVersion: 2, version: VERSION.package, runtime, root, config, configExisted, backup: merged.backup, generated, installedAt: new Date().toISOString() };
      await emit(receiptPath(root), `${JSON.stringify(record, null, 2)}\n`, true);
    } catch (error) {
      if (merged) await tx.rollback(config).catch(() => undefined);
      for (const file of generated) if (within(root, file.path) && await currentHash(file.path) === file.sha256) await rm(file.path, { force: true });
      await rm(`${config}.hrh-backup`, { force: true });
      if (!configExisted) await rm(config, { force: true });
      throw error;
    }
    process.stdout.write(`${JSON.stringify({ installed: true, scope: global ? 'global' : 'project', receipt: receiptPath(root), config, generated: generated.length })}\n`); return;
  }
  if (command === 'verify') {
    const root = resolve(option(args, '--project') ?? '.');
    const record = await receipt(root);
    const missing: string[] = [];
    const modified: string[] = [];
    for (const path of [record.config, ...generatedRecords(record).map(file => file.path)]) await access(path).catch(() => missing.push(path));
    for (const file of generatedRecords(record)) {
      const hash = await currentHash(file.path);
      if (hash !== undefined && (!file.sha256 || hash !== file.sha256)) modified.push(file.path);
    }
    const configText = await readFile(record.config, 'utf8').catch(() => '');
    const ok = record.receiptVersion === 2 && record.version === VERSION.package && missing.length === 0 && modified.length === 0 && /harness/i.test(configText);
    process.stdout.write(`${JSON.stringify({ ok, receiptVersion: record.receiptVersion ?? null, version: record.version, runtime: record.runtime, missing, modified })}\n`);
    if (!ok) process.exitCode = 1;
    return;
  }
  if (command === 'rollback') {
    const root = resolve(option(args, '--project') ?? '.');
    const record = await receipt(root);
    await new TransactionalConfig().rollback(record.config);
    process.stdout.write(`${JSON.stringify({ rolledBack: true, config: record.config })}\n`); return;
  }
  if (command === 'uninstall') {
    const root = resolve(option(args, '--project') ?? '.');
    const record = await receipt(root);
    if (record.configExisted === false) await rm(record.config, { force: true });
    else await new TransactionalConfig().rollback(record.config);
    await rm(record.backup, { force: true });
    let removed = 0;
    const preserved: string[] = [];
    for (const file of generatedRecords(record)) {
      const hash = await currentHash(file.path);
      if (within(root, file.path) && file.sha256 && hash === file.sha256) { await rm(file.path, { force: true }); removed += 1; }
      else if (hash !== undefined) preserved.push(file.path);
    }
    await rm(receiptPath(root), { force: true });
    process.stdout.write(`${JSON.stringify({ uninstalled: true, config: record.config, removed, preserved })}\n`); return;
  }
  if (command === 'version-check') {
    const report = await validateVersionAuthority(resolve(option(args, '--root') ?? '.'));
    process.stdout.write(`${JSON.stringify(report)}\n`);
    if (!report.ok) process.exitCode = 1;
    return;
  }
  if (command === 'doctor') {
    const checks = [
      { name: 'node', ok: Number(process.versions.node.split('.')[0]) >= 20, detail: process.versions.node },
      { name: 'version-authority', ...(await validateVersionAuthority(resolve(option(args, '--root') ?? packageRoot)).then(report => ({ ok: report.ok, detail: report }))) },
      { name: 'mcp-sdk', ok: await access(resolve(dirname(fileURLToPath(import.meta.url)), '../node_modules/@modelcontextprotocol/sdk')).then(() => true).catch(() => false), detail: 'pinned 1.30.0' }
    ];
    const report = { ok: checks.every(x => x.ok), checks };
    process.stdout.write(args.includes('--json') ? `${JSON.stringify(report)}\n` : `${JSON.stringify(report, null, 2)}\n`);
    if (!report.ok) process.exitCode = 1;
    return;
  }
  fail(`unknown command: ${command}`);
}

main(process.argv.slice(2)).catch(error => fail(error instanceof Error ? error.message : String(error)));

