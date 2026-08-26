#!/usr/bin/env node
import { access, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
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
async function emit(path: string, content: string): Promise<void> { await mkdir(dirname(path), { recursive: true }); await writeFile(path, content, { flag: 'w' }); }
type Receipt = { version: string; runtime: Runtime; root: string; config: string; backup: string; generated: string[]; installedAt: string };
const receiptPath = (root: string) => join(root, '.harness-re-harness/install.json');
async function receipt(root: string): Promise<Receipt> { return JSON.parse(await readFile(receiptPath(root), 'utf8')) as Receipt; }
function within(root: string, path: string): boolean { const relative = resolve(path).slice(resolve(root).length); return resolve(path).startsWith(`${resolve(root)}/`) && !relative.includes('..'); }

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
    if (!args[1] || args[1].startsWith('--')) fail('install requires a manifest path');
    const selected = option(args, '--runtime');
    if (!selected || !runtimes.includes(selected as Runtime)) fail(`--runtime must be one of: ${runtimes.join(', ')}`);
    const root = global ? homedir() : resolve(option(args, '--project') ?? '.');
    const runtime = selected as Runtime;
    const descriptor = runtimeConfig(runtime);
    const config = resolve(option(args, '--config') ?? join(root, descriptor.path));
    await access(config).catch(async () => emit(config, descriptor.format === 'json' || descriptor.format === 'jsonc' ? '{}\n' : ''));
    const tx = new TransactionalConfig();
    const merged = await tx.merge(config, descriptor.format, descriptor.patch);
    const generated: string[] = [];
    try {
      const compilation = compileRuntime(await load(args[1]), runtime);
      for (const file of compilation.files) {
        const target = join(root, file.path);
        if (resolve(target) === config) continue;
        await emit(target, file.content);
        generated.push(resolve(target));
      }
    } catch (error) {
      await tx.rollback(config);
      for (const path of generated) if (within(root, path)) await rm(path, { force: true });
      throw error;
    }
    const record: Receipt = { version: VERSION.package, runtime, root, config, backup: merged.backup, generated, installedAt: new Date().toISOString() };
    await emit(receiptPath(root), `${JSON.stringify(record, null, 2)}\n`);
    process.stdout.write(`${JSON.stringify({ installed: true, scope: global ? 'global' : 'project', receipt: receiptPath(root), config, generated: generated.length })}\n`); return;
  }
  if (command === 'verify') {
    const root = resolve(option(args, '--project') ?? '.');
    const record = await receipt(root);
    const missing: string[] = [];
    for (const path of [record.config, ...record.generated]) await access(path).catch(() => missing.push(path));
    const configText = await readFile(record.config, 'utf8').catch(() => '');
    const ok = record.version === VERSION.package && missing.length === 0 && /harness/i.test(configText);
    process.stdout.write(`${JSON.stringify({ ok, version: record.version, runtime: record.runtime, missing })}\n`);
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
    await new TransactionalConfig().rollback(record.config);
    for (const path of record.generated) if (within(root, path)) await rm(path, { force: true });
    await rm(receiptPath(root), { force: true });
    process.stdout.write(`${JSON.stringify({ uninstalled: true, config: record.config, removed: record.generated.length })}\n`); return;
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
