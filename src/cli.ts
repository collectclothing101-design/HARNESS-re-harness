#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { access, copyFile, mkdir, readFile, realpath, rm, writeFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { dirname, isAbsolute, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import process from 'node:process';
import { compileRuntime, runtimeConfig } from './compiler.js';
import { renderMergedConfig, TransactionalConfig } from './config.js';
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
type InstallJournal = { journalVersion: 1; version: string; runtime: Runtime; root: string; config: string; configExisted: boolean; originalConfigSha256: string; installedConfigSha256: string; backup: string; generated: GeneratedReceipt[]; startedAt: string };
const receiptPath = (root: string) => join(root, '.harness-re-harness/install.json');
const journalPath = (root: string) => join(root, '.harness-re-harness/transaction.json');
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
function crashAt(boundary: string): void {
  if (process.env.NODE_ENV === 'test' && process.env.HARNESS_RE_HARNESS_TEST_CRASH_AT === boundary) process.kill(process.pid, 'SIGKILL');
}
async function recoverPending(root: string): Promise<{ recovered: boolean; removed?: number; preserved?: string[]; reason?: string }> {
  if (!await exists(journalPath(root))) return { recovered: false, reason: 'no pending transaction' };
  const record = JSON.parse(await readFile(journalPath(root), 'utf8')) as InstallJournal;
  if (record.journalVersion !== 1 || resolve(record.root) !== root) fail('pending transaction journal does not match this installation root');
  if (!within(root, record.config) || record.generated.some(file => !within(root, file.path))) fail('pending transaction journal contains a path outside the installation root');
  await assertContained(root, record.config);
  for (const file of record.generated) await assertContained(root, file.path);

  const preserved: string[] = [];
  const configHash = await currentHash(record.config);
  if (record.configExisted) {
    if (configHash === undefined || configHash === record.installedConfigSha256) await copyFile(record.backup, record.config);
    else if (configHash !== record.originalConfigSha256) preserved.push(record.config);
  } else if (configHash === record.originalConfigSha256 || configHash === record.installedConfigSha256) {
    await rm(record.config, { force: true });
  } else if (configHash !== undefined) preserved.push(record.config);

  let removed = 0;
  for (const file of record.generated) {
    const hash = await currentHash(file.path);
    if (hash === file.sha256) { await rm(file.path, { force: true }); removed += 1; }
    else if (hash !== undefined) preserved.push(file.path);
  }
  if (preserved.length > 0) fail(`recovery preserved externally modified files; resolve them before retrying: ${preserved.join(', ')}`);

  if (await exists(receiptPath(root))) {
    const installed = await receipt(root).catch(() => undefined);
    if (!installed || installed.root !== record.root || installed.config !== record.config || installed.runtime !== record.runtime) fail('recovery preserved an unrecognized installation receipt');
    await rm(receiptPath(root), { force: true });
  }
  await rm(record.backup, { force: true });
  await rm(journalPath(root), { force: true });
  return { recovered: true, removed, preserved };
}

async function main(args: string[]): Promise<void> {
  const packageRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
  const command = args[0];
  if (!command || command === 'help' || args.includes('--help')) {
    process.stdout.write('harness-re-harness <validate|compile|install|recover|verify|rollback|uninstall|doctor|version|version-check|serve> [options]\n'); return;
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
    if (await exists(journalPath(root))) fail('pending installation transaction exists; run recover before installing');
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
    const configSeed = configExisted ? await readFile(config, 'utf8') : descriptor.format === 'json' || descriptor.format === 'jsonc' || descriptor.format === 'yaml' ? '{}\n' : '';
    const installedConfig = renderMergedConfig(configSeed, descriptor.format, descriptor.patch);
    const planned = targets.map(({ file, target }) => ({ path: target, sha256: sha256(file.content) }));
    const journal: InstallJournal = {
      journalVersion: 1,
      version: VERSION.package,
      runtime,
      root,
      config,
      configExisted,
      originalConfigSha256: sha256(configSeed),
      installedConfigSha256: sha256(installedConfig),
      backup: `${config}.hrh-backup`,
      generated: planned,
      startedAt: new Date().toISOString()
    };
    await emit(journalPath(root), `${JSON.stringify(journal, null, 2)}\n`, true);
    crashAt('after-journal');
    if (!configExisted) await emit(config, configSeed);
    const tx = new TransactionalConfig();
    let merged: { changed: boolean; backup: string } | undefined;
    const generated: GeneratedReceipt[] = [];
    try {
      merged = await tx.merge(config, descriptor.format, descriptor.patch, () => crashAt('after-backup'));
      crashAt('after-config');
      for (const { file, target } of targets) {
        await emit(target, file.content, true);
        generated.push({ path: target, sha256: sha256(file.content) });
        crashAt('after-asset');
      }
      const record: Receipt = { receiptVersion: 2, version: VERSION.package, runtime, root, config, configExisted, backup: merged.backup, generated, installedAt: new Date().toISOString() };
      await emit(receiptPath(root), `${JSON.stringify(record, null, 2)}\n`, true);
      crashAt('during-receipt');
      await rm(journalPath(root), { force: true });
    } catch (error) {
      await recoverPending(root).catch(() => undefined);
      throw error;
    }
    process.stdout.write(`${JSON.stringify({ installed: true, scope: global ? 'global' : 'project', receipt: receiptPath(root), config, generated: generated.length })}\n`); return;
  }
  if (command === 'recover') {
    const root = resolve(option(args, '--project') ?? '.');
    process.stdout.write(`${JSON.stringify(await recoverPending(root))}\n`); return;
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

