import test from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { access, mkdir, mkdtemp, readFile, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { parse as parseJsonc } from 'jsonc-parser';
import { parse as parseToml } from 'smol-toml';
import { parse as parseYaml } from 'yaml';

const valid = {
  schemaVersion: '1.0.0', packageVersion: '1.3.0', name: 'cli-demo',
  upstream: { repository: 'https://github.com/revfactory/harness', commit: '0123456789abcdef0123456789abcdef01234567' },
  agents: [{ id: 'builder', role: 'implementation', modelTier: 'balanced', skills: ['coding'], tools: ['filesystem'] }],
  skills: [{ id: 'coding', description: 'Implement code', triggers: ['implement'] }],
  workflows: [{ id: 'flow', pattern: 'pipeline', nodes: [{ id: 'build', agent: 'builder' }], edges: [], reviewGates: [] }],
  runtimeRequirements: ['agents', 'skills', 'tools', 'mcp']
};

function cli(args, cwd) {
  return spawnSync(process.execPath, [join(process.cwd(), 'dist/cli.js'), ...args], { cwd, encoding: 'utf8' });
}

function crashingCli(args, cwd, crashAt) {
  return spawnSync(process.execPath, [join(process.cwd(), 'dist/cli.js'), ...args], {
    cwd,
    encoding: 'utf8',
    env: { ...process.env, NODE_ENV: 'test', HARNESS_RE_HARNESS_TEST_CRASH_AT: crashAt }
  });
}

const sha256 = value => createHash('sha256').update(value).digest('hex');

function installedServer(runtime, text) {
  if (runtime === 'codex') return parseToml(text).mcp_servers.harness;
  if (runtime === 'hermes') return parseYaml(text).mcp_servers.harness;
  const parsed = runtime === 'mimo' || runtime === 'opencode' ? parseJsonc(text) : JSON.parse(text);
  return (parsed.mcp ?? parsed.mcpServers).harness;
}

test('CLI validates and compiles every runtime without global mutation', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-cli-'));
  const input = join(dir, 'harness.manifest.json');
  await writeFile(input, JSON.stringify(valid));
  assert.equal(cli(['validate', input], dir).status, 0);
  const runtimes = ['claude','codex','chatgpt','mimo','opencode','hermes','frank','generic'];
  for (const runtime of runtimes) assert.equal(cli(['compile', input, '--runtime', runtime, '--out', join(dir, 'generated')], dir).status, 0);
  assert.match(await readFile(join(dir, 'generated/.codex/config.toml'), 'utf8'), /mcp_servers\.harness/);
});

test('CLI rejects global installation unless explicitly opted in', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-cli-'));
  const result = cli(['install', '--global'], dir);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /--allow-global/);
});

test('CLI transactionally installs, verifies, rolls back, and uninstalls a runtime', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-install-'));
  const input = join(dir, 'harness.manifest.json');
  const config = join(dir, '.codex/config.toml');
  await writeFile(input, JSON.stringify(valid));
  await import('node:fs/promises').then(fs => fs.mkdir(join(dir, '.codex'), { recursive: true }));
  await writeFile(config, 'theme = "dark"\n');
  const installed = cli(['install', input, '--runtime', 'codex', '--project', dir, '--config', config], dir);
  assert.equal(installed.status, 0, installed.stderr);
  assert.match(await readFile(config, 'utf8'), /mcp_servers/);
  assert.equal(cli(['verify', '--project', dir], dir).status, 0);
  assert.equal(cli(['rollback', '--project', dir], dir).status, 0);
  assert.equal(await readFile(config, 'utf8'), 'theme = "dark"\n');
  assert.equal(cli(['uninstall', '--project', dir], dir).status, 0);
  await assert.rejects(access(join(dir, '.harness-re-harness/install.json')));
});

test('operational verify starts the installed descriptor and probes the MCP contract', async () => {
  for (const runtime of ['claude','codex','chatgpt','mimo','opencode','hermes','frank','generic']) {
    const dir = await mkdtemp(join(tmpdir(), `hrh-operational-${runtime}-`));
    const input = join(dir, 'harness.manifest.json');
    await writeFile(input, JSON.stringify(valid));
    const installed = cli(['install', input, '--runtime', runtime, '--project', dir], dir);
    assert.equal(installed.status, 0, `${runtime}: ${installed.stderr}`);

    const verified = cli(['verify', '--project', dir, '--operational', '--timeout-ms', '5000'], dir);
    assert.equal(verified.status, 0, `${runtime}: ${verified.stderr}`);
    const report = JSON.parse(verified.stdout);
    assert.equal(report.ok, true, runtime);
    assert.equal(report.operational.ok, true, runtime);
    assert.equal(report.operational.server.name, 'harness-re-harness', runtime);
    assert.ok(report.operational.tools.includes('harness_validate'), runtime);
    assert.ok(report.operational.resources.includes('harness://capabilities'), runtime);
    assert.ok(report.operational.prompts.includes('harness_plan'), runtime);
    assert.equal(report.operational.validCall, true, runtime);
    assert.equal(report.operational.invalidInputRejected, true, runtime);
    assert.equal(report.operational.shutdown, true, runtime);
  }
});

test('operational verify refuses a descriptor command that differs from the installed package', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-operational-tamper-'));
  const input = join(dir, 'harness.manifest.json');
  await writeFile(input, JSON.stringify(valid));
  const installed = cli(['install', input, '--runtime', 'codex', '--project', dir], dir);
  assert.equal(installed.status, 0, installed.stderr);
  const descriptor = JSON.parse(installed.stdout);
  const config = await readFile(descriptor.config, 'utf8');
  await writeFile(descriptor.config, config.replace(/^command = .*$/m, 'command = "/definitely/not-harness"'));

  assert.equal(cli(['verify', '--project', dir], dir).status, 0);
  const verified = cli(['verify', '--project', dir, '--operational'], dir);
  assert.notEqual(verified.status, 0);
  assert.match(verified.stderr, /descriptor.*does not match/i);
});

test('installed MCP launch descriptors start for every runtime from an unrelated working directory', async () => {
  const unrelated = await mkdtemp(join(tmpdir(), 'hrh-cwd-'));
  const runtimes = ['claude','codex','chatgpt','mimo','opencode','hermes','frank','generic'];
  for (const runtime of runtimes) {
    const dir = await mkdtemp(join(tmpdir(), `hrh-${runtime}-`));
    const input = join(dir, 'harness.manifest.json');
    await writeFile(input, JSON.stringify(valid));
    const installed = cli(['install', input, '--runtime', runtime, '--project', dir], dir);
    assert.equal(installed.status, 0, `${runtime}: ${installed.stderr}`);
    const descriptor = JSON.parse(installed.stdout);
    const server = installedServer(runtime, await readFile(descriptor.config, 'utf8'));
    const transport = new StdioClientTransport({ command: server.command, args: server.args, cwd: unrelated, stderr: 'pipe' });
    const client = new Client({ name: `acceptance-${runtime}`, version: '1.0.0' });
    await client.connect(transport);
    assert.ok((await client.listTools()).tools.some(tool => tool.name === 'harness_validate'), runtime);
    await client.close();
  }
});

test('install collision is rejected before any user-owned file or configuration changes', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-collision-'));
  const input = join(dir, 'harness.manifest.json');
  const config = join(dir, '.codex/config.toml');
  const agent = join(dir, '.codex/agents/builder.md');
  await mkdir(join(dir, '.codex/agents'), { recursive: true });
  await writeFile(input, JSON.stringify(valid));
  await writeFile(config, 'theme = "dark"\n');
  await writeFile(agent, 'user-owned\n');
  const beforeConfig = await readFile(config);
  const beforeAgent = await readFile(agent);

  const result = cli(['install', input, '--runtime', 'codex', '--project', dir, '--config', config], dir);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /collision/i);
  assert.deepEqual(await readFile(config), beforeConfig);
  assert.deepEqual(await readFile(agent), beforeAgent);
  await assert.rejects(access(`${config}.hrh-backup`));
  await assert.rejects(access(join(dir, '.harness-re-harness/install.json')));
});

test('reinstall and replace are rejected without mutating the existing installation', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-reinstall-'));
  const input = join(dir, 'harness.manifest.json');
  await writeFile(input, JSON.stringify(valid));
  const first = cli(['install', input, '--runtime', 'codex', '--project', dir], dir);
  assert.equal(first.status, 0, first.stderr);
  const installed = JSON.parse(first.stdout);
  const beforeConfig = await readFile(installed.config);
  const beforeReceipt = await readFile(installed.receipt);

  for (const extra of [[], ['--replace']]) {
    const repeated = cli(['install', input, '--runtime', 'codex', '--project', dir, ...extra], dir);
    assert.notEqual(repeated.status, 0);
    assert.match(repeated.stderr, extra.length ? /replace.*not supported/i : /receipt.*exists/i);
    assert.deepEqual(await readFile(installed.config), beforeConfig);
    assert.deepEqual(await readFile(installed.receipt), beforeReceipt);
  }
});

test('install rejects a symlinked asset parent that escapes the project root', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-symlink-'));
  const outside = await mkdtemp(join(tmpdir(), 'hrh-outside-'));
  const input = join(dir, 'harness.manifest.json');
  await writeFile(input, JSON.stringify(valid));
  await mkdir(join(dir, '.codex'), { recursive: true });
  await symlink(outside, join(dir, '.codex/agents'), 'dir');

  const result = cli(['install', input, '--runtime', 'codex', '--project', dir], dir);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /escapes installation root/i);
  await assert.rejects(access(join(outside, 'builder.md')));
  await assert.rejects(access(join(dir, '.harness-re-harness/install.json')));
});

test('receipt hashes protect externally modified generated assets during verify and uninstall', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-ownership-'));
  const input = join(dir, 'harness.manifest.json');
  const config = join(dir, '.codex/config.toml');
  await writeFile(input, JSON.stringify(valid));
  await mkdir(join(dir, '.codex'), { recursive: true });
  await writeFile(config, 'theme = "dark"\n');

  const installed = cli(['install', input, '--runtime', 'codex', '--project', dir, '--config', config], dir);
  assert.equal(installed.status, 0, installed.stderr);
  const receiptFile = join(dir, '.harness-re-harness/install.json');
  const receipt = JSON.parse(await readFile(receiptFile, 'utf8'));
  assert.equal(receipt.receiptVersion, 2);
  assert.ok(receipt.generated.length > 1);
  assert.ok(receipt.generated.every(file => /^[a-f0-9]{64}$/.test(file.sha256)));
  const modified = receipt.generated[0];
  await writeFile(modified.path, 'externally modified\n');

  const verified = cli(['verify', '--project', dir], dir);
  assert.notEqual(verified.status, 0);
  assert.deepEqual(JSON.parse(verified.stdout).modified, [modified.path]);
  const removed = receipt.generated[1];
  assert.equal(sha256(await readFile(removed.path)), removed.sha256);

  const uninstalled = cli(['uninstall', '--project', dir], dir);
  assert.equal(uninstalled.status, 0, uninstalled.stderr);
  assert.equal(await readFile(modified.path, 'utf8'), 'externally modified\n');
  await assert.rejects(access(removed.path));
  assert.equal(await readFile(config, 'utf8'), 'theme = "dark"\n');
  await assert.rejects(access(`${config}.hrh-backup`));
  await assert.rejects(access(receiptFile));
  assert.deepEqual(JSON.parse(uninstalled.stdout).preserved, [modified.path]);
});

test('recover rolls back hard-killed installs at each durable boundary and is idempotent', async () => {
  for (const crashAt of ['after-backup', 'after-config', 'after-asset', 'during-receipt']) {
    const dir = await mkdtemp(join(tmpdir(), `hrh-crash-${crashAt}-`));
    const input = join(dir, 'harness.manifest.json');
    const config = join(dir, '.codex/config.toml');
    await mkdir(join(dir, '.codex'), { recursive: true });
    await writeFile(input, JSON.stringify(valid));
    await writeFile(config, 'theme = "dark"\n');

    const interrupted = crashingCli(['install', input, '--runtime', 'codex', '--project', dir, '--config', config], dir, crashAt);
    assert.equal(interrupted.signal, 'SIGKILL', `${crashAt}: ${interrupted.stderr}`);
    assert.equal(await access(join(dir, '.harness-re-harness/transaction.json')).then(() => true, () => false), true, crashAt);

    const recovered = cli(['recover', '--project', dir], dir);
    assert.equal(recovered.status, 0, `${crashAt}: ${recovered.stderr}`);
    assert.equal(await readFile(config, 'utf8'), 'theme = "dark"\n', crashAt);
    await assert.rejects(access(`${config}.hrh-backup`));
    await assert.rejects(access(join(dir, '.harness-re-harness/install.json')));
    await assert.rejects(access(join(dir, '.harness-re-harness/transaction.json')));
    await assert.rejects(access(join(dir, '.codex/agents/builder.md')));

    const repeated = cli(['recover', '--project', dir], dir);
    assert.equal(repeated.status, 0, repeated.stderr);
    assert.deepEqual(JSON.parse(repeated.stdout), { recovered: false, reason: 'no pending transaction' });
  }
});

test('recover preserves post-crash user edits and retains evidence for manual resolution', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-crash-modified-'));
  const input = join(dir, 'harness.manifest.json');
  const config = join(dir, '.codex/config.toml');
  await mkdir(join(dir, '.codex'), { recursive: true });
  await writeFile(input, JSON.stringify(valid));
  await writeFile(config, 'theme = "dark"\n');

  const interrupted = crashingCli(['install', input, '--runtime', 'codex', '--project', dir, '--config', config], dir, 'after-config');
  assert.equal(interrupted.signal, 'SIGKILL');
  await writeFile(config, 'user changed this after the crash\n');

  const recovered = cli(['recover', '--project', dir], dir);
  assert.notEqual(recovered.status, 0);
  assert.match(recovered.stderr, /preserved externally modified files/i);
  assert.equal(await readFile(config, 'utf8'), 'user changed this after the crash\n');
  assert.equal(await access(`${config}.hrh-backup`).then(() => true, () => false), true);
  assert.equal(await access(join(dir, '.harness-re-harness/transaction.json')).then(() => true, () => false), true);
});

test('recover refuses a post-crash symlink swap without touching the outside target', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-crash-symlink-'));
  const outside = await mkdtemp(join(tmpdir(), 'hrh-crash-outside-'));
  const input = join(dir, 'harness.manifest.json');
  const config = join(dir, '.codex/config.toml');
  await mkdir(join(dir, '.codex'), { recursive: true });
  await writeFile(input, JSON.stringify(valid));
  await writeFile(config, 'theme = "dark"\n');

  const interrupted = crashingCli(['install', input, '--runtime', 'codex', '--project', dir, '--config', config], dir, 'after-config');
  assert.equal(interrupted.signal, 'SIGKILL');
  await symlink(outside, join(dir, '.codex/agents'), 'dir');

  const recovered = cli(['recover', '--project', dir], dir);
  assert.notEqual(recovered.status, 0);
  assert.match(recovered.stderr, /escapes installation root/i);
  await assert.rejects(access(join(outside, 'builder.md')));
  assert.match(await readFile(config, 'utf8'), /mcp_servers/);
  assert.equal(await access(join(dir, '.harness-re-harness/transaction.json')).then(() => true, () => false), true);
});

test('doctor returns machine-readable checks', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-cli-'));
  const result = cli(['doctor', '--json'], dir);
  assert.equal(result.status, 0);
  const report = JSON.parse(result.stdout);
  assert.equal(report.ok, true);
  assert.ok(report.checks.length >= 3);
});

