import test from 'node:test';
import assert from 'node:assert/strict';
import { access, mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const valid = {
  schemaVersion: '1.0.0', packageVersion: '1.0.0', name: 'cli-demo',
  upstream: { repository: 'https://github.com/revfactory/harness', commit: '0123456789abcdef0123456789abcdef01234567' },
  agents: [{ id: 'builder', role: 'implementation', modelTier: 'balanced', skills: ['coding'], tools: ['filesystem'] }],
  skills: [{ id: 'coding', description: 'Implement code', triggers: ['implement'] }],
  workflows: [{ id: 'flow', pattern: 'pipeline', nodes: [{ id: 'build', agent: 'builder' }], edges: [], reviewGates: [] }],
  runtimeRequirements: ['agents', 'skills', 'tools', 'mcp']
};

function cli(args, cwd) {
  return spawnSync(process.execPath, [join(process.cwd(), 'dist/cli.js'), ...args], { cwd, encoding: 'utf8' });
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

test('doctor returns machine-readable checks', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-cli-'));
  const result = cli(['doctor', '--json'], dir);
  assert.equal(result.status, 0);
  const report = JSON.parse(result.stdout);
  assert.equal(report.ok, true);
  assert.ok(report.checks.length >= 3);
});
