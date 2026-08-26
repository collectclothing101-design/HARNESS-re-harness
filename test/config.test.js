import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile, access } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { TransactionalConfig } from '../dist/index.js';

test('transactional JSONC merge preserves unrelated settings and is idempotent', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-'));
  const file = join(dir, 'config.jsonc');
  await writeFile(file, '{\n  // keep me\n  "theme": "dark"\n}\n');
  const tx = new TransactionalConfig();
  await tx.merge(file, 'jsonc', { mcp: { harness: { command: 'node', args: ['server.js'] } } });
  const once = await readFile(file, 'utf8');
  await tx.merge(file, 'jsonc', { mcp: { harness: { command: 'node', args: ['server.js'] } } });
  assert.equal(await readFile(file, 'utf8'), once);
  assert.match(once, /keep me/);
  assert.match(once, /"theme": "dark"/);
  await access(`${file}.hrh-backup`);
});

test('failed validation leaves original file intact', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-'));
  const file = join(dir, 'config.json');
  await writeFile(file, '{"safe":true}\n');
  const tx = new TransactionalConfig();
  await assert.rejects(tx.merge(file, 'json', { bad: BigInt(1) }));
  assert.equal(await readFile(file, 'utf8'), '{"safe":true}\n');
});

test('rollback restores backup', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-'));
  const file = join(dir, 'config.yaml');
  await writeFile(file, 'theme: dark\n');
  const tx = new TransactionalConfig();
  await tx.merge(file, 'yaml', { mcp: { enabled: true } });
  await tx.rollback(file);
  assert.equal(await readFile(file, 'utf8'), 'theme: dark\n');
});

for (const [format, initial] of [['toml', 'theme = "dark"\n'], ['yaml', 'theme: dark\n']]) {
  test(`transactional ${format} merge remains parseable`, async () => {
    const dir = await mkdtemp(join(tmpdir(), 'hrh-'));
    const file = join(dir, `config.${format}`);
    await writeFile(file, initial);
    const tx = new TransactionalConfig();
    await tx.merge(file, format, { mcp_servers: { harness: { command: 'node' } } });
    const output = await readFile(file, 'utf8');
    assert.match(output, /harness/);
    assert.match(output, /dark/);
  });
}
